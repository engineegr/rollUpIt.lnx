#### Web Hosting

1. ##### Main roles

    1. Client

    2. Web app firewall (ModSecurity)

    3. Load balancer (HA proxy, Nginx)

    4. Cache proxy (Nginx, Varnish, Squid)

    5. Web Application (Tomcat, Unicorn)

    6. DB

2. ##### Http

    - HTTP header parameter:

        - TCP keep: `Connection: Keep-Alive`

        - Non-cachable: `Cache-control: no-cache, no-store`

3. ##### Cache 

    - Browser cache (on client side)

    - Reverse cache (on organiztion network boundaries)

    - Intercept cache (aka Proxy cache, on Provider side)

    To force no-cache request: 

    `curl -H "Cache control: no-cache"`
