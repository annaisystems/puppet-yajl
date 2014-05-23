# Class: yajl::params
#
class yajl::params {
  $install_from_source = true
  $install_dev = false
  $version = '1.0.12'
  $supported_versions = ['1.0.12', '2.1.0']
  $libname = 'libyajl'

  case $::osfamily {
    'RedHat': {
      $package = 'yajl'
      $package_dev = 'yajl-devel'
      $libsuffix = $::hardwaremodel ? {
        'x86_64' => '64',
        default  => ''
      }
      $download_command = "curl -L -o"
    }

    'Debian': {
      $package = 'libyajl1'
      $package_dev = 'libyajl-dev'
      $libsuffix = ''
      $download_command = "wget -O"
    }

    default: {
      fail("${module_name}: ${::osfamily} is not supported, only RedHat and Debian are supported")
    }
  }

  $libdest = "/usr/lib${libsuffix}"
}
