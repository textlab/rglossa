#! /usr/bin/env python2
# -*- coding: utf-8 -*-

import Tkinter
import math
import sys
import os
import os.path
import socket
import subprocess
import time
import traceback
import json
import signal
import atexit

global_config = json.load(open(sys.argv[1]))
os.environ['TCLLIBPATH'] = os.path.join(global_config['snack_dir'], 'lib', 'snack2.2')
sys.path.append(os.path.join(global_config['snack_dir'], 'lib',
                             'python%d.%d' % sys.version_info[:2], 'site-packages'))
import tkSnack

class GenWaveForm(Tkinter.Tk):
  starttime = time.time()
  conf = global_config

  def __init__(self, *args, **kwargs):
    Tkinter.Tk.__init__(self, *args, **kwargs)
    self.canvas = None
    self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    self.socket.bind(('127.0.0.1', self.conf['listen_port']))
    self.socket.listen(5)
    atexit.register(delete_pidfile)
    create_pidfile()
    self.after(100, self.secondary_init)

  def log(self, msg):
    print('%.2f: %.2f: %s' % (time.time(), time.time() - self.starttime, msg))
    sys.stdout.flush()

  def secondary_init(self):
    conn, addr = self.socket.accept()
    self.starttime = time.time()
    self.log('Connected')
    self.filesocket = conn.makefile()
    conn.close()
    sndfile = self.filesocket.readline().rstrip()
    if '/' in sndfile:
      raise Exception('%s: slashes not allowed' % sndfile)
    outfile = '.'.join(sndfile.split('.')[:-1])
    self.sndfile = '%s/%s' % (self.conf['output_dir'], sndfile)
    self.outfile = '%s/%s' % (self.conf['output_dir'], outfile)
    self.snd = tkSnack.Sound(load=self.sndfile)

    num_samples = self.snd.info()[0]
    sampling_rate = self.snd.info()[1]
    self.log('num_samples=%d' % num_samples)
    self.log('sampling_rate=%d' % sampling_rate)

    self.split_points = range(0, num_samples, 60*sampling_rate) + [num_samples]
    self.tmpfiles = []
    # iterate from len(self.split_points)-2 down to 0:
    self.i = len(self.split_points)-2
    self.after(100, self.generate_stuff1)

  def generate_stuff1(self):
      self.fname = '%s-%d-wave.jpg' % (self.outfile, self.i)
      self.tmpfiles.insert(0, self.fname)

      self.log('range %d' % self.i)
      self.fragment = tkSnack.Sound()
      self.fragment.copy(self.snd, start=self.split_points[self.i],
                         end=self.split_points[self.i+1])

      num_samples = self.fragment.info()[0]
      sampling_rate = self.fragment.info()[1]
      self.width = self.conf['pixels_per_second'] * num_samples / sampling_rate

      self.log('create waveform & spectrogram, width = %d' % self.width)
      if self.canvas:
        self.canvas.destroy()
      self.canvas = tkSnack.SnackCanvas(height=self.conf['total_height'], width=self.width,
                                        bg='white', highlightthickness=0)
      self.canvas.create_waveform(1, 1, sound=self.fragment, height=self.conf['waveform_height'],
                                  pixelspersec=self.conf['pixels_per_second'])
      self.canvas.create_spectrogram(1, self.conf['waveform_height'], sound=self.fragment,
                                     height=self.conf['total_height']-self.conf['waveform_height'],
                                     pixelspersec=self.conf['pixels_per_second'],
                                     topfrequency=10000)

      self.log('generating %s' % self.fname)
      self.canvas.pack()
      self.after(100, self.do_import1)

  def do_import1(self):
    self.log('calling import')
    subprocess.call(['import', '-display', os.getenv('DISPLAY'), '-window', 'root',
                               '-crop', '%dx%d+1+0' % (self.width-1, self.conf['total_height']),
                               '-transparent', 'white',
                               '-quality', '50', self.fname])
    self.log('import ended')
    self.after(100, self.generate_stuff2)

  def generate_stuff2(self):
      self.fname = '%s-%d-fmt.png' % (self.outfile, self.i)
      self.log('create formants')
      spec = self.fragment.formant(start=0)
      self.log('create formant points')
      if self.canvas:
        self.canvas.destroy()
      self.canvas = tkSnack.SnackCanvas(height=self.conf['total_height'], width=self.width,
                                        bg='white', highlightthickness=0)
      for x, y in enumerate(spec):
        xx = x*0.01*self.conf['pixels_per_second']
        for j, colour in [(0, 'red'), (1, 'green'), (2, 'blue'), (3, 'orange')]:
          yy = self.conf['waveform_height'] + (self.conf['total_height']-self.conf['waveform_height']) * (4000-y[j])/4000.0
          self.canvas.create_rectangle(xx, yy, xx+1, yy+1, outline=colour)

      self.log('generating %s' % self.fname)
      self.canvas.pack()
      self.after(100, self.do_import2)

  def do_import2(self):
    self.log('calling import')
    subprocess.call(['import', '-display', os.getenv('DISPLAY'), '-window', 'root',
                                        '-crop', '%dx%d+1+0' % (self.width-1, self.conf['total_height']),
                                        '-transparent', 'white',
                                        '-quality', '50', self.fname])
    self.log('import ended')
    self.after(100, self.generate_stuff3)

  def generate_stuff3(self):
      self.fname = '%s-%d-pitch.png' % (self.outfile, self.i)
      self.log('create pitch')
      spec = self.fragment.pitch(start=0, method='esps')
      self.log('create pitch points')
      if self.canvas:
        self.canvas.destroy()
      self.canvas = tkSnack.SnackCanvas(height=self.conf['total_height'], width=self.width, bg='white',
                                        highlightthickness=0)
      for x, y in enumerate(spec):
        xx = x*0.01*self.conf['pixels_per_second']
        yy = self.conf['waveform_height'] + (self.conf['total_height']-self.conf['waveform_height']) * (1000-y[0])/1000.0
        self.canvas.create_rectangle(xx, yy, xx+1, yy+1, outline='black')

      self.log('generating %s' % self.fname)
      self.canvas.pack()
      self.after(100, self.do_import3)

  def do_import3(self):
    self.log('calling import')
    subprocess.call(['import', '-display', os.getenv('DISPLAY'), '-window', 'root',
                                        '-crop', '%dx%d+1+0' % (self.width-1, self.conf['total_height']),
                                        '-transparent', 'white',
                                        '-quality', '50', self.fname])
    self.log('import ended')
    self.i -= 1
    if self.i >= 0:
      self.after(100, self.generate_stuff1)
    else:
      self.log('done')
      self.filesocket.close()
      self.after(100, self.secondary_init)

  def show_error(self, *args):
    self.cleanup()
    traceback.print_exception(*args)
    sys.stdout.flush()
    sys.stderr.flush()
    self.restart()

  def cleanup(self):
    if hasattr(self, 'filesocket') and self.filesocket:
      self.filesocket.close()
    if hasattr(self, 'socket') and self.socket:
      self.socket.close()
    sys.stdout.flush()
    sys.stderr.flush()

  def restart(self):
    os.execl(sys.argv[0], sys.argv[0], sys.argv[1], sys.argv[2])

  def sighandler(self, signo, frame):
    self.cleanup()
    if signo == signal.SIGHUP:
      self.after(100, self.restart)
    else:
      sys.exit(0)

def create_pidfile():
  with open(sys.argv[2], 'w') as f:
    print >>f, os.getpid()

def delete_pidfile():
  os.remove(sys.argv[2])

tkSnack.initializeSnack(Tkinter.Tk())
Tkinter.Tk.report_callback_exception = GenWaveForm.show_error
root = GenWaveForm()
signal.signal(signal.SIGTERM, root.sighandler)
signal.signal(signal.SIGHUP, root.sighandler)
root.mainloop()