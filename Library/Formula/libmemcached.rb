require 'formula'

class Libmemcached <Formula
  url 'http://download.tangent.org/libmemcached-0.43.tar.gz'
  homepage 'http://libmemcached.org'
  md5 'f6940255a1889871ef3a29f430370950'

  depends_on 'memcached'

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end