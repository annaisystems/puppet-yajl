# Class: yajl
#
class yajl (
  $ensure = 'present',
  $version = $yajl::params::version,
  $install_from_source = $yajl::params::install_from_source,
  $install_dev = $yajl::params::dev,
  $package = $yajl::params::package,
  $package_dev= $yajl::params::package_dev,
) inherits yajl::params {

  if ! $install_from_source {
    package { $package:
      ensure => $ensure,
    }

    if $install_dev {
      package { $package_dev:
        ensure => $ensure,
      }
    }
  }

  else {
    if ($version != '') and !member($supported_versions, $version) {
      fail("${module_name}: $version is not a supported version")
    }

    $source_package = "yajl-${version}.tar.gz"
    $source_url = "http://github.com/lloyd/yajl/tarball/${version}"

    include cmake
    exec { 'download yajl source':
      command => "${download_command} ${source_package} ${source_url}",
      cwd     => '/tmp',
      unless  => "file -f ${libdest}/${libname}.so.${version}",
      notify  => Exec['extract yajl source']
    }
    exec { 'extract yajl source':
      command     => "rm -rf yajl_src && mkdir yajl_src && tar -C yajl_src --strip-components=1 -xzf ${source_package} && mkdir /tmp/yajl_src/build",
      cwd         => '/tmp',
      refreshonly => true,
      notify      => Exec['build and install yajl'],
    }
    exec { 'build and install yajl':
      command     => "cmake -DLIB_SUFFIX=${libsuffix} -DCMAKE_INSTALL_PREFIX:PATH=/usr .. && make install",
      cwd         => '/tmp/yajl_src/build',
      refreshonly => true,
      require     => Class['cmake'],
      notify      => Exec['cleanup yajl source'],
    }
    exec { 'cleanup yajl source':
      command     => "rm -rf /tmp/yajl_src",
      refreshonly => true,
    }
  }
}
