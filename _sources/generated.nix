# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  kubernetes-core = {
    pname = "kubernetes-core";
    version = "2.4.0";
    src = fetchurl {
      url = "https://galaxy.ansible.com/download/kubernetes-core-2.4.0.tar.gz";
      sha256 = "sha256-NxNYCIb4+bUJ9c4JzuNgZ1zkWxcOU2Mdkwe3bR3Nvyw=";
    };
  };
}
