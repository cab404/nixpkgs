{ pkgs
, buildGoModule
, fetchFromGithub
, lib
 }:
let
  virt-manager-without-menu = pkgs.virt-viewer.overrideAttrs(x: {
    patches = [
      ./patches/0001-Remove-menu-bar.patch
      ./patches/0002-Do-not-grab-keyboard-mouse.patch
      ./patches/0003-Use-name-of-appvm-applications-as-a-title.patch
      ./patches/0004-Use-title-application-name-as-subtitle.patch
    ];
  });
in with pkgs;

buildGoModule rec {
  pname = "appvm";
  version = "0.5";

  goPackagePath = "code.dumpstack.io/tools/${pname}";

  buildInputs = [ makeWrapper ];

  src = fetchFromGitHub {
    owner = "jollheef";
    repo = "appvm";
    rev = "v${version}";
    sha256 = "1l1919avx2dggp50frrys0d9l6s8j0928m7zlpz38wmc1q0aihxw";
  };

  vendorSha256 = "1y41p7xjkrj3rqarw72hjckv180zh9dfz30zp629ynwpxsrwsxai";

  postFixup = ''
    wrapProgram $out/bin/appvm \
      --prefix PATH : "${lib.makeBinPath [ nix virt-manager-without-menu ]}"
  '';

  meta = with lib; {
    description = "Nix-based app VMs";
    homepage = "https://code.dumpstack.io/tools/${pname}";
    maintainers = with maintainers; [ dump_stack cab404 ];
    license = licenses.gpl3;
  };
}
