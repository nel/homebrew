require 'formula'

class Exim <Formula
  url 'http://ftp.exim.org/pub/exim/exim4/exim-4.71.tar.gz'
  homepage 'http://exim.org'
  sha1 '8198c70892ba8ce1a1c550b0d19bc7590814c535'

  depends_on 'pcre'

  def install
    FileUtils.cp 'src/EDITME', 'Local/Makefile'
    inreplace 'Local/Makefile' do |s|
      s.remove_make_var! "EXIM_MONITOR"
      s.change_make_var! "EXIM_USER", ENV['USER']
      s.change_make_var! "SYSTEM_ALIASES_FILE", etc + 'aliases'
      s.gsub!('/usr/exim/configure', etc + 'exim.conf')
      s.gsub!('/usr/exim', prefix)
      s.gsub!('/var/spool/exim', var + 'spool/exim')
    end
     
    inreplace 'OS/Makefile-Darwin' do |s|
      s.remove_make_var! %w{CC CFLAGS}
    end
    
    system "make"
    system "make INSTALL_ARG=-no_chown install"
    (man + 'man8').install 'doc/exim.8'
    (bin + 'exim_ctl').write startup_script
  end
  
  #inspired from macports startup script, but with fixed restart issue due to missing setuid
  def startup_script
    return <<-END
#!/bin/sh
PID=#{var+'spool/exim/exim-daemon.pid'}
case "$1" in
start)
  echo "starting exim mail transfer agent"
  #{bin+'exim'} -bd -q30m
  ;;
restart)
  echo "restarting exim mail transfer agent"
  /bin/kill -15 `/bin/cat $PID` && sleep 1 && #{bin+'exim'} -bd -q30m
  ;;
stop)
  echo "stopping exim mail transfer agent"
  /bin/kill -15 `/bin/cat $PID`
  ;;
*)
  echo "Usage: #{bin+'exim_ctl'} {start|stop|restart}"
  exit 1
  ;;
esac
END
  end
  
  def caveats
    "Start with exim_ctl start, don't forget to run it as root to be able to bind port 25"
  end
end