# source: http://jhshi.me/2014/03/21/switch-channel-without-breaking-tcp-connection-in-openwrt/index.html#.XHPtIRBgnHx

def set_channel(channel) :

  # do not use the wifi command to switch channel, but still maintain the
  # channel coheraence of the configuration file

  args = ['uci', 'set']

  if channel <= 11 :
    args.append('wireless.radio0.channel=' + str(channel))
  else :
    args.append('wireless.radio1.channel=' + str(channel))

  subprocess.call(args)
  subprocess.call(['uci', 'commit'])

  # this is the command that actually switches channel

  with open(os.devnull, 'wb') as f :
    cmd = 'chan_switch 1 ' + str(channel2freq(channel)) + '\n'
    p = subprocess.Popen('hostapd_cli', stdin=subprocess.PIPE, stdout=f, stderr=f)
    p.stdin.write(cmd)
    time.sleep(3)
    p.kill()