#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import json
import solargraph_utils

# TODO ちゃんとテストクライアント化する
# TODO テスト書く

# text = ''.join(open(os.path.expanduser('~/tmp/smp.rb')).readlines())
# line = 81
# column = 11

# path = os.path.expanduser('~/codes/ictsc-score-server/controllers/scoreboard.rb')
# text = ''.join(open(path).readlines())
# line = 12
# column = 2

text = "String."
line = 0
column = 7

server = solargraph_utils.Server(command='solargraph')

print(server.url)
# print(text)

client = solargraph_utils.Client(server.url)
# result = client.suggest(text=text, line=line, column=column, filename=path, workspace=os.path.dirname(path))
result = client.suggest(text=text, line=line, column=column)

print(json.dumps(result, indent=4, sort_keys=True))

server.stop()
