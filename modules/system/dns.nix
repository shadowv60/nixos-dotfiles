{ pkgs, ... }:
{
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      server_names = [
        "cloudflare"
        "nextdns"
      ];
      listen_addresses = [ "127.0.0.1:53" ];
      ipv6_servers = false;
      require_dnssec = true;
      require_nolog = true;
      require_nofilter = true;
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      blocked_names = {
        blocked_names_file = "/var/cache/dnscrypt-proxy/blocked-names.txt";
        log_file = "/var/log/dnscrypt-proxy/blocked-names.log";
      };
    };
  };

  system.activationScripts.dnscrypt-blocklist-init = ''
    mkdir -p /var/cache/dnscrypt-proxy
    mkdir -p /var/log/dnscrypt-proxy
    if [ ! -f /var/cache/dnscrypt-proxy/blocked-names.txt ]; then
      touch /var/cache/dnscrypt-proxy/blocked-names.txt
    fi
  '';

  systemd.services.dnscrypt-proxy-blocklist = {
    description = "Fetch dnscrypt-proxy blocklist";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "120";
      ExecStart = pkgs.writeShellScript "fetch-blocklist" ''
        set -e
        HOST="raw.githubusercontent.com"

        # Resolve via a public DNS server directly, bypassing the local
        # stub resolver (dnscrypt-proxy) which may not be bootstrapped yet.
        # This avoids hardcoding a static IP -- we always get a fresh answer.
        IP=""
        for DNS in 1.1.1.1 8.8.8.8 9.9.9.9; do
          IP=$(${pkgs.dnsutils}/bin/dig +time=3 +tries=1 +short "@$DNS" "$HOST" A | grep -m1 -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
          if [ -n "$IP" ]; then
            break
          fi
        done

        if [ -n "$IP" ]; then
          ${pkgs.curl}/bin/curl -sSfL --retry 5 --retry-delay 3 --retry-connrefused \
            --resolve "$HOST:443:$IP" \
            "https://$HOST/hagezi/dns-blocklists/main/domains/pro.txt" \
            -o /var/cache/dnscrypt-proxy/blocked-names.txt
        else
          # Fall back to normal resolution in case dnscrypt-proxy is
          # actually ready by now.
          ${pkgs.curl}/bin/curl -sSfL --retry 8 --retry-delay 5 --retry-connrefused \
            "https://$HOST/hagezi/dns-blocklists/main/domains/pro.txt" \
            -o /var/cache/dnscrypt-proxy/blocked-names.txt
        fi

        systemctl restart dnscrypt-proxy.service
      '';
    };
  };

  systemd.timers.dnscrypt-proxy-blocklist = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  networking.nameservers = [ "127.0.0.1" ];
  services.resolved.enable = false;
}
