#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import sys
import base64
import urllib2
import json
import os

message = sys.argv[1]

tts_url = 'http://rospeex.ucri.jgn-x.jp/nauth_json/jsServices/VoiceTraSS'
tts_command = {'method': 'speak',
               'params': ['1.1',
                          {'language': 'ja', 'text': message, 'voiceType': "*", 'audioType': "audio/x-wav"}]
               }

# request
req = urllib2.Request(tts_url, json.dumps(tts_command))
received = urllib2.urlopen(req).read()

# extract wav data
audio_data = json.loads(received)['result']['audio'] # extract result->audio
speech = base64.decodestring(audio_data.encode('utf-8'))

output = "/tmp/rsay-output.wav"
f = open(output, 'wb')
f.write(speech)
f.close

os.system("cvlc --no-daemon --no-one-instance '%s'" % output)
