#!/usr/bin/env python2
# -*- coding: euc-jp -*-

'''
PyCOMET2, COMET II emulator implemented in Python.
Copyright (c) 2009, Masahiko Nakamoto.
All rights reserved.

Based on a simple implementation of COMET II emulator.
Copyright (c) 2001-2008, Osamu Mizuno.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
'''

import sys, os, string, array
from optparse import OptionParser, OptionValueError
import logging

# argtypeに与える引数の種類
noarg, r, r1r2, adrx, radrx, ds, dc, strlen = [0, 1, 2, 3, 4, 5, 6, 7]
# 機械語命令のバイト長
inst_size = {noarg:1, r:1, r1r2:1, adrx:2, radrx:2, ds:-1, dc:-1, strlen:3}
# スタックポインタの初期値
initSP = 0xff00

''' unsigned -> signed '''
def l2a(x):
    x &= 0xffff
    if 0x0000 <= x <= 0x7fff:
        a = x
    elif 0x8000 <= x <= 0xffff:
        a = x - 2**16
    else:
        raise TypeError
    return a

''' signed -> unsigned '''
def a2l(x):
    x &= 0xffff
    if 0 <= x:
        return x
    return x + 2**16

''' xのnビット目の値を返す (最下位ビットがn = 0)'''
def get_bit(x, n):
    if x & (0x01 << n) == 0:
        return 0
    else:
        return 1

'''
命令の基底クラス
'''
class Instruction:
    def __init__(self, machine, opcode=0x00, opname='None', argtype=noarg):
        self.m = machine
        self.opcode = opcode
        self.opname = opname
        self.argtype = argtype
        self.disassemble_functions = {noarg:self.disassemble_noarg,
                                      r:    self.disassemble_r,
                                      r1r2: self.disassemble_r1r2,
                                      adrx: self.disassemble_adrx,
                                      radrx:self.disassemble_radrx,
                                      strlen:self.disassemble_strlen}

    def get_r(self, addr = None):
        if addr == None:
            addr = self.m.PR
        a = self.m.memory[addr]
        return (0x00f0 & a) >> 4

    def get_r1r2(self, addr = None):
        if addr == None:
            addr = self.m.PR
        a = self.m.memory[addr]
        r1 = ((0x00f0 & a) >> 4)
        r2 = (0x000f & a)
        return r1, r2

    def get_adrx(self, addr = None):
        if addr == None:
            addr = self.m.PR
        a = self.m.memory[addr]
        b = self.m.memory[addr+1]
        x = (0x000f & a)
        adr = b
        return adr, x

    def get_radrx(self, addr = None):
        if addr == None:
            addr = self.m.PR
        a = self.m.memory[addr]
        b = self.m.memory[addr+1]
        r = ((0x00f0 & a) >> 4)
        x = (0x000f & a)
        adr = b
        return r, adr, x

    def get_strlen(self, addr = None):
        if addr == None:
            addr = self.m.PR
        s = self.m.memory[addr+1]
        l = self.m.memory[addr+2]
        return s, l

    '''
    計算結果に応じてフラグを立てる
    デフォルトは算術演算用
    論理演算の場合は第二引数をTrueにする
    '''
    def update_flags(self, result, isLogical = False):
        # ゼロ
        if result == 0:
            self.m.ZF = 1
        else:
            self.m.ZF = 0

        # 符号
        if get_bit(result, 15) == 0:
            self.m.SF = 0
        else:
            self.m.SF = 1

        # オーバーフロー
        if isLogical == True:
            if result < 0 or 0xffff < result:
                self.m.OF = 1
            else:
                self.m.OF = 0
        else:
            if result < -32768 or 0x7fff < result:
                self.m.OF = 1
            else:
                self.m.OF = 0

    ''' 実効アドレスを返す '''
    def get_effective_address(self, adr, x):
        if x == 0:
            return adr
        else:
            return a2l(adr + self.m.GR[x])


    ''' 実効アドレス番地の値を返す '''
    def get_value_at_effective_address(self, adr, x):
        if x == 0:
            return self.m.memory[adr]
        else:
            return self.m.memory[a2l(adr + self.m.GR[x])]

    def disassemble(self, address):
        return self.disassemble_functions[self.argtype](address)

    def disassemble_noarg(self, address):
        return '%--8s' % self.opname

    def disassemble_r(self, address):
        r = self.get_r(address)
        return '%-8sGR%1d' % (self.opname, r)

    def disassemble_r1r2(self, address):
        r1, r2 = self.get_r1r2(address)
        return '%-8sGR%1d, GR%1d' % (self.opname, r1, r2)

    def disassemble_adrx(self, address):
        adr, x = self.get_adrx(address)
        if x == 0:
            return '%-8s#%04x' % (self.opname, adr)
        else:
            return '%-8s#%04x, GR%1d' % (self.opname, adr, x)

    def disassemble_radrx(self, address):
        r, adr, x = self.get_radrx(address)
        if x == 0:
            return '%-8sGR%1d, #%04x' % (self.opname, r, adr)
        else:
            return '%-8sGR%1d, #%04x, GR%1d' % (self.opname, r, adr, x)

    def disassemble_strlen(self, address):
        s, l = self.get_strlen(address)
        return '%-8s#%04x, #%04x' % (self.opname, s, l)



''' No OPeration '''
class NOP(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x00, 'NOP', noarg)

    def execute(self):
        self.m.PR += 1

''' LoaD (FR) '''
class LD2(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x10, 'LD', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        self.m.GR[r] = self.get_value_at_effective_address(adr, x)
        self.update_flags(self.m.GR[r])
        self.m.OF = 0
        self.m.PR += 2

''' STore '''
class ST(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x11, 'ST', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        self.m.memory[self.get_effective_address(adr, x)] = self.m.GR[r]
        self.m.PR += 2

''' Load ADress '''
class LAD(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x12, 'LAD', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        self.m.GR[r] = self.get_effective_address(adr, x)
        self.m.PR += 2

''' LoaD (FR) '''
class LD1(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x14, 'LD', r1r2)

    def execute(self):
        r1, r2 = self.get_r1r2()
        self.m.GR[r1] = self.m.GR[r2]
        self.update_flags(self.m.GR[r1])
        self.m.OF = 0
        self.m.PR += 1


class ADDA2(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x20, 'ADDA', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_value_at_effective_address(adr, x)
        result = l2a(self.m.GR[r]) + l2a(v)
        self.m.GR[r] = a2l(result)
        self.update_flags(result)
        self.m.PR += 2


class ADDA1(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x24, 'ADDA', r1r2)

    def execute(self):
        r1, r2 = self.get_r1r2()
        result = l2a(self.m.GR[r1]) + l2a(self.m.GR[r2])
        self.m.GR[r1] = a2l(result)
        self.update_flags(result)
        self.m.PR += 1


class SUBA2(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x21, 'SUBA', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_value_at_effective_address(adr, x)
        result = l2a(self.m.GR[r]) - l2a(v)
        self.m.GR[r] = a2l(result)
        self.update_flags(result)
        self.m.PR += 2


class SUBA1(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x25, 'SUBA', r1r2)

    def execute(self):
        r1, r2 = self.get_r1r2()
        result = l2a(self.m.GR[r1]) - l2a(self.m.GR[r2])
        self.m.GR[r1] = a2l(result)
        self.update_flags(result)
        self.m.PR += 1


class ADDL2(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x22, 'ADDL', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_value_at_effective_address(adr, x)
        result = self.m.GR[r] + v
        self.m.GR[r] = result & 0xffff
        self.update_flags(result, True)
        self.m.PR += 2

class ADDL1(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x26, 'ADDL', r1r2)

    def execute(self):
        r1, r2 = self.get_r1r2()
        result = self.m.GR[r1] + self.m.GR[r2]
        self.m.GR[r1] = result & 0xffff
        self.update_flags(result, True)
        self.m.PR += 1


class SUBL2(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x23, 'SUBL', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_value_at_effective_address(adr, x)
        result = self.m.GR[r] - v
        self.m.GR[r] = result & 0xffff
        self.update_flags(result, True)
        self.m.PR += 2


class SUBL1(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x27, 'SUBL', r1r2)

    def execute(self):
        r1, r2 = self.get_r1r2()
        result = self.m.GR[r1] - self.m.GR[r2]
        self.m.GR[r1] = result & 0xffff
        self.update_flags(result, True)
        self.m.PR += 1


''' AND '''
class AND2(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x30, 'AND', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_value_at_effective_address(adr, x)
        self.m.GR[r] = self.m.GR[r] & v
        self.update_flags(self.m.GR[r])
        self.m.OF = 0
        self.m.PR += 2

class OR2(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x31, 'OR', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_value_at_effective_address(adr, x)
        self.m.GR[r] = self.m.GR[r] | v
        self.update_flags(self.m.GR[r])
        self.m.OF = 0
        self.m.PR += 2

class XOR2(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x32, 'XOR', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_value_at_effective_address(adr, x)
        self.m.GR[r] = self.m.GR[r] ^ v
        self.update_flags(self.m.GR[r])
        self.m.OF = 0
        self.m.PR += 2


class AND1(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x34, 'AND', r1r2)

    def execute(self):
        r1, r2 = self.get_r1r2()
        self.m.GR[r1] = self.m.GR[r1] & self.m.GR[r2]
        self.update_flags(self.m.GR[r1])
        self.m.OF = 0
        self.m.PR += 1


class OR1(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x35, 'OR', r1r2)

    def execute(self):
        r1, r2 = self.get_r1r2()
        self.m.GR[r1] = self.m.GR[r1] | self.m.GR[r2]
        self.update_flags(self.m.GR[r1])
        self.m.OF = 0
        self.m.PR += 1


class XOR1(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x36, 'XOR', r1r2)

    def execute(self):
        r1, r2 = self.get_r1r2()
        self.m.GR[r1] = self.m.GR[r1] ^ self.m.GR[r2]
        self.update_flags(self.m.GR[r1])
        self.m.OF = 0
        self.m.PR += 1

''' ComPare Arithmetic '''
class CPA2(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x40, 'CPA', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_value_at_effective_address(adr, x)
        diff = l2a(self.m.GR[r]) - l2a(v)
        if diff > 0:
            self.m.SF, self.m.ZF = 0, 0
        elif diff == 0:
            self.m.SF, self.m.ZF = 0, 1
        else:
            self.m.SF, self.m.ZF = 1, 0

        self.m.OF = 0
        self.m.PR += 2

''' ComPare Logical '''
class CPL2(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x41, 'CPL', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_value_at_effective_address(adr, x)
        diff = self.m.GR[r] - v
        if diff > 0:
            self.m.SF, self.m.ZF = 0, 0
        elif diff == 0:
            self.m.SF, self.m.ZF = 0, 1
        else:
            self.m.SF, self.m.ZF = 1, 0

        self.m.OF = 0
        self.m.PR += 2

''' ComPare Arithmetic '''
class CPA1(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x44, 'CPA', r1r2)

    def execute(self):
        r1, r2 = self.get_r1r2()
        diff = l2a(self.m.GR[r1]) - l2a(self.m.GR[r2])
        if diff > 0:
            self.m.SF, self.m.ZF = 0, 0
        elif diff == 0:
            self.m.SF, self.m.ZF = 0, 1
        else:
            self.m.SF, self.m.ZF = 1, 0

        self.m.OF = 0
        self.m.PR += 1

''' ComPare Logical '''
class CPL1(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x45, 'CPL', r1r2)

    def execute(self):
        r1, r2 = self.get_r1r2()
        diff = self.m.GR[r1] - self.m.GR[r2]
        if diff > 0:
            self.m.SF, self.m.ZF = 0, 0
        elif diff == 0:
            self.m.SF, self.m.ZF = 0, 1
        else:
            self.m.SF, self.m.ZF = 1, 0

        self.m.OF = 0
        self.m.PR += 1

''' Shift Left Arithmetic (FR, OR) '''
class SLA(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x50, 'SLA', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_effective_address(adr, x)
        p = l2a(self.m.GR[r])
        prev_p = p
        sign = get_bit(self.m.GR[r], 15)
        ans = (p << v) & 0x7fff
        if sign == 0:
            ans = ans & 0x7fff
        else:
            ans = ans | 0x8000
        self.m.GR[r] = ans
        self.update_flags(self.m.GR[r])
        if 0 < v:
            self.m.OF = get_bit(prev_p, 15-v)
        self.m.PR += 2

''' Shift Right Arithmetic (FR, OR) '''
class SRA(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x51, 'SRA', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_effective_address(adr, x)
        p = l2a(self.m.GR[r])
        prev_p = p
        sign = get_bit(self.m.GR[r], 15)
        ans = (p >> v) & 0x7fff
        if sign == 0:
            ans = ans & 0x7fff
        else:
            ans = ans | 0x8000
        self.m.GR[r] = ans
        self.update_flags(self.m.GR[r])
        if 0 < v:
            self.m.OF = get_bit(prev_p, v-1)
        self.m.PR += 2

''' Shift Left Logical (FR, OR) '''
class SLL(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x52, 'SLL', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_effective_address(adr, x)
        p = self.m.GR[r]
        prev_p = p
        ans = p << v
        ans = ans & 0xffff
        self.m.GR[r] = ans
        self.update_flags(self.m.GR[r], True)
        if 0 < v:
            self.m.OF = get_bit(prev_p, 15 - (v-1))
        self.m.PR += 2

''' Shift Right Logical (FR, OR) '''
class SRL(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x53, 'SRL', radrx)

    def execute(self):
        r, adr, x = self.get_radrx()
        v = self.get_effective_address(adr, x)
        p = self.m.GR[r]
        prev_p = p
        ans = self.m.GR[r] >> v
        ans = ans & 0xffff
        self.m.GR[r] = ans
        self.update_flags(self.m.GR[r])
        if 0 < v:
            self.m.OF = get_bit(prev_p, (v-1))
        self.m.PR += 2

''' Jump on MInus
SF = 1のときジャンプ '''
class JMI(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x61, 'JMI', adrx)

    def execute(self):
        adr, x = self.get_adrx()
        if self.m.SF == 1:
            self.m.PR = self.get_effective_address(adr, x)
            return
        else:
            self.m.PR += 2

''' Jump on Non Zero
ZF = 0のときジャンプ '''
class JNZ(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x62, 'JNZ', adrx)

    def execute(self):
        adr, x = self.get_adrx()
        if self.m.ZF == 0:
            self.m.PR = self.get_effective_address(adr, x)
            return
        else:
            self.m.PR += 2

''' Jump on ZEro
ZF = 1のときジャンプ '''
class JZE(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x63, 'JZE', adrx)

    def execute(self):
        adr, x = self.get_adrx()
        if self.m.ZF == 1:
            self.m.PR = self.get_effective_address(adr, x)
            return
        else:
            self.m.PR += 2

''' unconditional JUMP
無条件にジャンプ '''
class JUMP(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x64, 'JUMP', adrx)

    def execute(self):
        adr,x = self.get_adrx()
        self.m.PR = self.get_effective_address(adr, x)

''' Jump on PLus
OF = 0 and SF = 0 のときジャンプ '''
class JPL(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x65, 'JPL', adrx)

    def execute(self):
        adr, x = self.get_adrx()
        if self.m.ZF == 0 and self.m.SF == 0:
            self.m.PR = self.get_effective_address(adr, x)
            return
        else:
            self.m.PR += 2

''' Jump on OVerflow
OF = 1のときジャンプ '''
class JOV(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x66, 'JOV', adrx)

    def execute(self):
        adr, x = self.get_adrx()
        if self.m.OF == 1:
            self.m.PR = self.get_effective_address(adr, x)
            return
        else:
            self.m.PR += 2


class PUSH(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x70, 'PUSH', adrx)

    def execute(self):
        adr, x = self.get_adrx()
        self.m.setSP(self.m.getSP()-1)
        self.m.memory[self.m.getSP()] = self.get_effective_address(adr, x)
        self.m.PR += 2

class POP(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x71, 'POP', r)

    def execute(self):
        r = self.get_r()
        self.m.GR[r] = self.m.memory[self.m.getSP()]
        self.m.setSP(self.m.getSP()+1)
        self.m.PR += 1

''' CALL subroutine '''
class CALL(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x80, 'CALL', adrx)

    def execute(self):
        adr, x = self.get_adrx()
        self.m.setSP(self.m.getSP()-1)
        self.m.memory[self.m.getSP()] = self.m.PR
        self.m.PR = self.get_effective_address(adr, x)
        self.m.call_level += 1

''' RETurn from subroutine '''
class RET(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x81, 'RET', noarg)

    def execute(self):
        if self.m.call_level == 0:
            # self.m.step_count += 1
            # self.m.exit()
            print('program finished')
            return True;
        self.m.PR = self.m.memory[self.m.getSP()] + 2
        self.m.setSP(self.m.getSP()+1)
        self.m.call_level -= 1


''' SuperVisor Call '''
class SVC(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0xf0, 'SVC', adrx)

    def execute(self):
        pass

class IN(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x90, 'IN', strlen)

    def execute(self):
        s, l = self.get_strlen()
        sys.stderr.write('-> ')
        sys.stderr.flush()
        line = sys.stdin.readline()
        line = line[:-1]
        if 256 < len(line):
            line = line[0:256]
        self.m.memory[l] = len(line)
        for i,ch in enumerate(line):
            self.m.memory[s+i] = ord(ch)
        self.m.PR += 3

class OUT(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0x91, 'OUT', strlen)

    def execute(self):
        s, l = self.get_strlen()
        length = self.m.memory[l]
        # print >> sys.stderr, "%04x, %04x, %d" % (s, l, length)
        ch = ''
        for i in range(s, s+length):
            try:
                # ch += chr(self.m.memory[i])
                ch += unichr(self.m.memory[i])
            except ValueError, e:
                print >> sys.stderr, "Error:"
                self.m.print_status()
                self.m.dump(s)
        print ch.encode('utf-8')
        self.m.PR += 3

class RPUSH(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0xa0, 'RPUSH', noarg)

    def execute(self):
        for i in range(1, 9):
            self.m.setSP(self.m.getSP()-1)
            self.m.memory[self.m.getSP()] = self.m.GR[i]
        self.m.PR += 1

class RPOP(Instruction):
    def __init__(self, machine):
        Instruction.__init__(self, machine, 0xa1, 'RPOP', noarg)

    def execute(self):
        for i in range(1, 9)[::-1]:
            self.m.GR[i] = self.m.memory[self.m.getSP()]
            self.m.setSP(self.m.getSP()+1)
        self.m.PR += 1



class pyComet2:
    class InvalidOperation(BaseException):
        def __init__(self, address):
            self.address = address
        def __str__(self):
            return 'Invalid operation is found at #%04x.' % self.address

    class StatusMonitor:
        def __init__(self, machine):
            self.m = machine
            self.format = '%04d: '
            self.var_list = ['self.m.step_count']
            self.decimalFlag = False

        def __str__(self):
            variables = ""
            for v in self.var_list:
                variables += v + ","
            return eval("'%s' %% (%s)" % (self.format, variables))

        def append(self, s):
            if len(self.format) != 6:
                self.format += ", "

            try:
                if s == 'PR':
                    self.format += "PR=#%04x"
                    self.var_list.append('self.m.PR')
                elif s == 'OF':
                    self.format += "OF=%01d"
                    self.var_list.append('self.m.OF')
                elif s == 'SF':
                    self.format += "SF=%01d"
                    self.var_list.append('self.m.SF')
                elif s == 'ZF':
                    self.format += "ZF=%01d"
                    self.var_list.append('self.m.ZF')
                elif s[0:2] == 'GR':
                    if int(s[2]) < 0 or 8 < int(s[2]):
                        raise
                    if self.decimalFlag:
                        self.format += s[0:3] +"=%d"
                    else:
                        self.format += s[0:3] +"=#%04x"
                    self.var_list.append('self.m.GR[' + s[2] + ']')
                else:
                    adr = self.m.cast_int(s)
                    if adr < 0 or 0xffff < adr:
                        raise
                    if self.decimalFlag:
                        self.format += "#%04x" % adr + "=%d"
                    else:
                        self.format += "#%04x" % adr + "=#%04x"
                    self.var_list.append('self.m.memory[%d]' % adr )
            except:
                print >> sys.stderr, "Warning: Invalid monitor target is found. %s is ignored." % s

    def __init__(self):
        self.inst_list = [NOP, LD2, ST, LAD, LD1,
                          ADDA2, SUBA2, ADDL2, SUBL2,
                          ADDA1, SUBA1, ADDL1, SUBL1,
                          AND2, OR2, XOR2, AND1, OR1, XOR1,
                          CPA2, CPL2, CPA1, CPL1,
                          SLA, SRA, SLL, SRL,
                          JMI, JNZ, JZE, JUMP, JPL, JOV,
                          PUSH, POP, CALL, RET, SVC,
                          IN, OUT, RPUSH, RPOP]

        self.inst_table = {}
        for c in self.inst_list:
            i = c(self)
            self.inst_table[i.opcode] = i

        self.isAutoDump = False
        self.break_points = []
        self.call_level = 0
        self.step_count = 0
        self.monitor = self.StatusMonitor(self)

        self.initialize()

    def initialize(self):
        self.memory = array.array('H', [0]*65536) # 主記憶 1 word = 2 byte unsigned short
        self.GR = array.array('H', [0]*9) # レジスタ unsigned short
        self.setSP(initSP) # スタックポインタ SP = GR[8]
        self.PR = 0 # プログラムレジスタ
        self.OF = 0 # Overflow Flag
        self.SF = 0 # Sign Flag
        self.ZF = 1 # Zero Flag
        logging.info('Initialize memory and registers.')

    def setSP(self, value):
        self.GR[8] = value

    def getSP(self):
        return self.GR[8]

    def print_status(self):
        try:
            code = self.getInstruction().disassemble(self.PR)
        except:
            code = '%04x' % self.memory[self.PR]
        sys.stderr.write('PR  #%04x [ %-30s ]  STEP %d\n' % (self.PR, code, self.step_count) )
        sys.stderr.write('SP  #%04x(%7d) FR(OF, SF, ZF)  %03s  (%7d)\n' % (self.getSP(), self.getSP(),
                                                                           self.getFRasString(), self.getFR()))
        sys.stderr.write('GR0 #%04x(%7d) GR1 #%04x(%7d) GR2 #%04x(%7d) GR3: #%04x(%7d)\n'
                         % (self.GR[0], l2a(self.GR[0]), self.GR[1], l2a(self.GR[1]),
                            self.GR[2], l2a(self.GR[2]), self.GR[3], l2a(self.GR[3])))
        sys.stderr.write('GR4 #%04x(%7d) GR5 #%04x(%7d) GR6 #%04x(%7d) GR7: #%04x(%7d)\n'
                         % (self.GR[4], l2a(self.GR[4]), self.GR[5], l2a(self.GR[5]),
                            self.GR[6], l2a(self.GR[6]), self.GR[7], l2a(self.GR[7])))


    def exit(self):
        if self.isCountStep:
            print 'Step count:', self.step_count

        if self.isAutoDump:
            print >> sys.stderr, "dump last status to last_state.txt"
            self.dump_to_file('last_state.txt')

        sys.exit()

    def set_auto_dump(self, flg):
        self.isAutoDump = flg

    def set_count_step(self, flg):
        self.isCountStep = flg

    def setLoggingLevel(self, lv):
        logging.basicConfig(level=lv)

    def getFR(self):
        return self.OF << 2 | self.SF << 1 | self.ZF

    def getFRasString(self):
        return str(self.OF) + str(self.SF) + str(self.ZF)

    # PRが指す命令を返す
    def getInstruction(self, adr = None):
        try:
            if adr == None:
                adr = self.PR
            return self.inst_table[(self.memory[adr] & 0xff00) >> 8]
        except KeyError:
            raise self.InvalidOperation(adr)

    # 命令を1つ実行
    def step(self):
        ret = self.getInstruction().execute()
        self.step_count += 1
        return ret

    def watch(self, variables, decimalFlag=False):
        self.monitor.decimalFlag = decimalFlag
        for v in variables.split(","):
            self.monitor.append(v)

        while (True):
            if self.PR in self.break_points:
                break
            else:
                try:
                    print self.monitor
                    sys.stdout.flush()
                    self.step()
                except self.InvalidOperation, e:
                    print >> sys.stderr, e
                    self.dump(e.address)
                    break

    def run(self):
        while (True):
            if self.PR in self.break_points:
                break
            else:
                try:
                    if self.step() is not None:
                        break
                except self.InvalidOperation, e:
                    print >> sys.stderr, e
                    self.dump(e.address)
                    break

    # オブジェクトコードを主記憶に読み込む
    def load(self, filename, quiet=False):
        if not quiet:
            print >> sys.stderr, 'load %s ...' % filename,
        self.initialize()
        fp = file(filename, 'rb')
        try:
            tmp = array.array('H')
            tmp.fromfile(fp, 65536)
        except EOFError:
            pass
        fp.close()
        tmp.byteswap()
        self.PR = tmp[2]
        tmp = tmp[8:]
        for i in range(0, len(tmp)):
            self.memory[i] = tmp[i]
        if not quiet:
            print >> sys.stderr, 'done.'

    def dump_memory(self, start_addr = 0x0000, lines = 0xffff / 8):
        def to_char(array):
            def chr2(i):
                c = 0x00ff & i
                if chr(c) in (string.letters + string.digits + string.punctuation + ' ') :
                    return chr(c)
                else:
                    return '.'

            return reduce(lambda x,y: x+y, [chr2(i) for i in array])

        def to_hex(array):
            return reduce(lambda x,y: x+' '+y, ['%04x' % i for i in array])

        st = ''
        for i in range(0, lines):
            addr = i * 8 + start_addr
            if 0xffff < addr: return
            st += '%04x: %-39s %-8s\n' % (addr, to_hex(self.memory[addr:addr+8]), to_char(self.memory[addr:addr+8]))
        return st

    # 8 * 16 wordsダンプする
    def dump(self, start_addr = 0x0000):
        print self.dump_memory(start_addr, 16),

    def dump_stack(self):
        print self.dump_memory(self.getSP(), 16),

    def dump_to_file(self, filename, lines = 0xffff / 8):
        fp = file(filename, 'w')
        fp.write('Step count: %d\n' % self.step_count)
        fp.write('PR: #%04x\n' % self.PR)
        fp.write('SP: #%04x\n' % self.getSP())
        fp.write('OF: %1d\n' % self.OF)
        fp.write('SF: %1d\n' % self.SF)
        fp.write('ZF: %1d\n' % self.ZF)
        for i in range(0, 8):
            fp.write('GR%d: #%04x\n' % (i, self.GR[i]))
        fp.write('Memory:\n')
        fp.write(self.dump_memory(0, lines))
        fp.close()

    def disassemble(self, start_addr = 0x0000):
        addr = start_addr
        for i in range(0, 16):
            try:
                inst = self.getInstruction(addr)
                if inst != None:
                    print >> sys.stderr, '#%04x\t#%04x\t%s' % (addr, self.memory[addr], inst.disassemble(addr))
                    if 1 < inst_size[inst.argtype]:
                        print >> sys.stderr, '#%04x\t#%04x' % (addr+1, self.memory[addr+1])
                    if 2 < inst_size[inst.argtype]:
                        print >> sys.stderr, '#%04x\t#%04x' % (addr+2, self.memory[addr+2])
                    addr += inst_size[inst.argtype]
                else:
                    print >> sys.stderr, '#%04x\t#%04x\t%s' % (addr, self.memory[addr], '%-8s#%04x' % ('DC', self.memory[addr]))
                    addr += 1
            except:
                print >> sys.stderr, '#%04x\t#%04x\t%s' % (addr, self.memory[addr], '%-8s#%04x' % ('DC', self.memory[addr]))
                addr += 1

    def cast_int(self, addr):
        if addr[0] == '#':
            return int(addr[1:], 16)
        elif addr[0:2] == '0x':
            return int(addr[2:], 16)
        else:
            return int(addr)

    def set_break_point(self, addr):
        if addr in self.break_points:
            print >> sys.stderr, '#%04x is already set.' % addr
        else:
            self.break_points.append(addr)

    def print_break_points(self):
        if len(self.break_points) == 0:
            print >> sys.stderr, 'No break points.'
        else:
            for i, addr in enumerate(self.break_points):
                print >> sys.stderr, '%d: #%04x' % (i, addr)

    def delete_break_points(self, n):
        if 0 <= n < len(self.break_points):
            print >> sys.stderr, '#%04x is removed.' % (self.break_points[n])
        else:
            print >> sys.stderr, 'Invalid number is specified.'

    def write_memory(self, addr, value):
        self.memory[addr] = value

    def jump(self, addr):
        self.PR = addr
        self.print_status()

    def wait_for_command(self):
        while True:
            sys.stderr.write('pycomet2> ')
            sys.stderr.flush()
            line = sys.stdin.readline()
            args = line.split()
            if line[0] == 'q':
                break
            elif line[0] == 'b':
                if 2 <= len(args):
                    self.set_break_point(self.cast_int(args[1]))
            elif line[0:2] == 'df':
                self.dump_to_file(args[1])
                print >> sys.stderr, 'dump to', filename
            elif line[0:2] == 'di':
                if len(args) == 1:
                    self.disassemble()
                else:
                    self.disassemble(self.cast_int(args[1]))
            elif line[0:2] == 'du':
                if len(args) == 1:
                    self.dump()
                else:
                    self.dump(self.cast_int(args[1]))
            elif line[0] == 'd':
                if 2 <= len(args):
                    self.delete_break_points(int(args[1]))
            elif line[0] == 'h':
                self.print_help()
            elif line[0] == 'i':
                self.print_break_points()
            elif line[0] == 'j':
                self.jump(self.cast_int(args[1]))
            elif line[0] == 'm':
                self.write_memory(self.cast_int(args[1]), self.cast_int(args[2]))
            elif line[0] == 'p':
                self.print_status()
            elif line[0] == 'r':
                self.run()
            elif line[0:2] == 'st':
                self.dump_stack()
            elif line[0] == 's':
                try:
                    self.step()
                except self.InvalidOperation, e:
                    print >> sys.stderr, e
                    self.dump(e.address)

                self.print_status()
            else:
                print >> sys.stderr, 'Invalid command.'

    def print_help(self):
        print >> sys.stderr, 'b ADDR        Set a breakpoint at specified address.'
        print >> sys.stderr, 'd NUM         Delete breakpoints.'
        print >> sys.stderr, 'di ADDR       Disassemble 32 words from specified address.'
        print >> sys.stderr, 'du ADDR       Dump 128 words of memory.'
        print >> sys.stderr, 'h             Print help.'
        print >> sys.stderr, 'i             Print breakpoints.'
        print >> sys.stderr, 'j ADDR        Set PR to ADDR.'
        print >> sys.stderr, 'm ADDR VAL    Change the memory at ADDR to VAL.'
        print >> sys.stderr, 'p             Print register status.'
        print >> sys.stderr, 'q             Quit.'
        print >> sys.stderr, 'r             Strat execution of program.'
        print >> sys.stderr, 's             Step execution.'
        print >> sys.stderr, 'st            Dump 128 words of stack image.'


def main():
    usage = 'usage: %prog [options] input.com'
    parser = OptionParser(usage)
    parser.add_option('-c', '--count-step', action='store_true', dest='count_step', default=False, help='count step.')
    parser.add_option('-d', '--dump', action='store_true', dest='dump', default=False, help='dump last status to last_state.txt.')
    parser.add_option('-r', '--run', action='store_true', dest='run', default=False, help='run')
    parser.add_option('-w', '--watch', type='string', dest='watchVariables', default='', help='run in watching mode. (ex. -w PR,GR0,GR8,#001f)')
    parser.add_option('-D', '--Decimal', action='store_true', dest='decimalFlag', default=False, help='watch GR[0-8] and specified address in decimal notation. (Effective in watcing mode only)')
    parser.add_option('-v', '--version', action='store_true', dest='version', default=False, help='display version information.')
    options, args = parser.parse_args()

    if options.version:
        print 'PyCOMET2 version 1.2.1'
        print '$Revision: a31dbeeb4d1c $'
        print 'Copyright (c) 2009, Masahiko Nakamoto.'
        print 'All rights reserved.'
        sys.exit()

    if len(args) < 1:
        parser.print_help()
        sys.exit()

    comet2 = pyComet2()
    comet2.set_auto_dump(options.dump)
    comet2.set_count_step(options.count_step)
    if len(options.watchVariables) != 0:
        comet2.load(args[0], True)
        comet2.watch(options.watchVariables, options.decimalFlag)
    elif options.run:
        comet2.load(args[0], True)
        comet2.run()
    else:
        comet2.load(args[0])
        comet2.print_status()
        comet2.wait_for_command()

if __name__ == '__main__':
    main()
