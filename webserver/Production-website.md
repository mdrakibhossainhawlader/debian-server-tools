# Setting up a production WordPress website

Not only a WordPress site!

1. [Installation](#installation)
1. [Migration](#migration)
1. [Upgrade](#upgrade)
1. [Check](#check)
1. [Monitor](#monitor)
1. [Backup](#backup)
1. [Uninstallation](#uninstallation)


## Installation


### DNS setup

- A, CNAME (for [CDN](http://www.cdnplanet.com/cdns/))
- MX
- SPF, DKIM
- Proper TTL values

### SSL certificate

- For safety (personal data)
- For security (less attacks)
- For trust (green lock in browsers)
- For better SEO ranking
- For speed (enables HTTP/2)
- For receiving referrer information (up to April 2012)
- Very cheap

Providers: Let's Encrypt,
[RapidSSL](https://cheapsslsecurity.com/sslbrands/rapidssl.html) (GeoTrust/Symantec),
CloudFlare SSL,
[SSL Certificate authorities](https://www.netcraft.com/internet-data-mining/ssl-survey/)

OCSP performance: http://uptime.netcraft.com/perf/reports/performance/OCSP

1. [Apache-SSL.md](./Apache-SSL.md)
1. https://www.ssllabs.com/ssltest/ :snail:
1. https://crt.sh/

### WordPress core, theme from git

1. Set up database connection in `wp-config.php`
1. Define constants, generate salts based on [wp-config.php skeleton](./wp-config.php)
1. Edit `../wp-cli.yml`
1. **Use child theme** for purchased themes
1. Keep custom themes in git `git clone --recursive ssh://user@server:port/path/to/git`

### Plugins

- Plugin licenses, access to support :snail:
- See plugin list in [WordPress.md](./WordPress.md#plugins)
- See MU plugins at https://github.com/szepeviktor/wordpress-plugin-construction
- Allow accents in URL-s? `mu-latin-accent-urls`

### Root files

- `/robots.txt` :snail:
- `/favicon.ico` :snail:
- `/apple-touch-icon.png` :snail:
- `/browserconfig.xml`
- [other files in the document root](https://github.com/szepeviktor/RootFiles)

### Maintenance mode and placeholder page

- Static all-inline HTML page
- `ErrorDocument 503 nice-page.html` + `RewriteRule "^" - [R=503,L]` + Retry-After header

### CDN

- Consider a CDN with multiple A records `host -t A cdn.example.com` :snail:
- [Revving filenames](http://www.stevesouders.com/blog/2008/08/23/revving-filenames-dont-use-querystring/)
- Combine and minify CSS and JavaScript files
- HTML caching or `no-cache`?
- Disallow HTML pages on CDN (robots-cdn.txt)
- https://aws.amazon.com/console/
- https://www.cloudflare.com/a/login see also [/webserver/CloudFlare.md](/webserver/CloudFlare.md)

### Mail sending

```bash
wp plugin install --activate wp-mailfrom-ii smtp-uri
wp eval 'wp_mail("admin@szepe.net","first outgoing",site_url());'
```

- Obfuscate email addresses `antispambot( 'e@ma.il' )`
- [JavaScript href fallback](https://gist.github.com/joshdick/961154): https://www.google.com/recaptcha/admin#mailhide
- Authenticated delivery for email notifications
- Shortest route of delivery
- Add server as `RELAYCLIENT` on the smarthost
- Email `From:` name and address
- Subject line
- Easy identification for email notifications (filtering to mail folders)
- SPF
- DKIM

Consider transactional email service through HTTP API. :snail:

- Mailgun API: https://wordpress.org/plugins/mailgun/
- Amazon SES: https://github.com/humanmade/aws-ses-wp-mail
- Mandrill API for WordPress: https://github.com/danielbachhuber/mandrill-wp-mail
- SparkPost API WordPress plugin: https://wordpress.org/plugins/sparkpost/

### Security

- WAF [`wordpress-fail2ban`](https://github.com/szepeviktor/wordpress-fail2ban) :snail:
- _For shared hosting: Sucuri Scanner plugin_
- _[Ninja Firewall Pro](http://ninjafirewall.com/pro/download.php)_
- _PHP extension: ionCube24 `ic24.enable = on` (PHP file modification time protection)_
- File change notification
- Subresource Integrity (SRI) `integrity="sha256-$(cat resource.js|openssl dgst -sha256 -binary|openssl enc -base64)" crossorigin="anonymous"`
- Google Search Console ("This site may harm your computer" notification on SERP)
- Sucuri SiteCheck (includes Google Safe Browsing)
- Virustotal (HTTP API)
- Maximum security: convert website into static HTML +
  [doorbell](https://doorbell.io/) or [formspree](https://formspree.io/) or [FormKeep](https://formkeep.com/)
  `simply-static`, `static-html-output-plugin`

### Cron jobs

Remove left-over WP-Cron events.

`wp cron event list; wp cron schedule list`

Use real cron job. :snail:

`wp-cron-cli.sh`

### WordPress Settings

- General Settings
- Writing Settings
- Reading Settings
- Media Settings (fewer generated image sizes) :snail:
- Permalink Settings
- WP Mail From :snail:

### User management

- 1 administrator :snail:
- Personal accounts for editors and authors :snail:
- Correct post and page authors
- Enable/disable author sitemaps

### RSS feed

@TODO

- Number of posts
- Full content
- Images
- Comment feeds

### Signature as HTML comment

```html
<!-- Infrastructure, source code management and support: Viktor Szépe <viktor@szepe.net> -->
```

### Webmaster tools

- Google Search Console :snail:
- Bing Webmaster
- Yandex Webmaster


## Migration


### Search & replace URL and installation path

Replace constants in `wp-config.php`.

`wp search-replace --precise --recurse-objects --all-tables-with-prefix ${OLD} ${NEW}`

1. `http://DOMAIN.TLD/wp-includes` -> `https://NEW-DOMAIN.TLD/SITE/wp-includes` (no trailing slash)
1. `//DOMAIN.TLD/wp-includes` -> `//NEW-DOMAIN.TLD/SITE/wp-includes` (no trailing slash)
1. `http://DOMAIN.TLD/wp-content` -> `https://NEW-DOMAIN.TLD/static` (no trailing slash)
1. `//DOMAIN.TLD/wp-content` -> `//NEW-DOMAIN.TLD/static` (no trailing slash)
1. `http://DOMAIN.TLD` (no trailing slash)
1. `//DOMAIN.TLD` (no trailing slash)
1. `/home/PATH/TO/SITE` (no trailing slash)
1. `EMAIL@ADDRESS.ES` (all addresses)
1. `DOMAIN.TLD` (now without protocol)

Check `home` and `siteurl`.

```bash
wp option get home
wp option get siteurl
```

### Uploads, media

```bash
wp media regenerate --skip-delete --only-missing
```

Remove missing (base) images.

### Clean up database

Check database collation and table storage engines.

See [alter-table.sql](/mysql/alter-table.sql)

Delete transients and object cache.

```bash
wp plugin install --activate wp-sweep
wp transient delete-all
wp db query "DELETE FROM $(wp eval 'global $table_prefix;echo $table_prefix;')options WHERE option_name LIKE '%_transient_%'"
wp cache flush
```

Flush page cache.

```bash
wp w3-total-cache flush
ls -l /home/${U}/website/html/static/cache/
ls -l /home/${U}/website/pagespeed/; touch /home/${U}/website/pagespeed/cache.flush
```

Check spam and trash comments.

```bash
wp comment list --status=spam --format=count
wp comment list --status=trash --format=count
```

Optimize database tables.

```bash
wp db optimize
```

### Remove development and testing stuff

- Sample / Demo content :snail:
- Code editor configuration file `.editorconfig`
- Files: `find -iname "*example*" -or -iname "*sample*" -or -iname "*demo*"`
- PHP-FPM pool configuration: `env[WP_ENV] = production`

### VCS

Put custom theme and plugins under git version control. :snail:

Keep git directory above document root.

### Redirect old URL-s (SEO)

`wp plugin install --activate safe-redirect-manager`

`https://www.google.com/search?q=site:DOMAIN`

Also redirect popular images.

### Flush Google public DNS cache

http://google-public-dns.appspot.com/cache :snail:


## Upgrade


### Things to stop before upgrade

- External monitoring - wait for Pingdom - `maintenance5.sh`
- Requests from the Internet - Apache - `service apache stop`
- Cron jobs (maintenance mode) - `service cron stop`
- Monitoring - Monit - `monit quit`
- Incoming emails piped into programs - Courier - disable alias


## Check


[What people remember on your website](https://zurb.com/helio) :snail:

### Marketing

- [One-person video team](https://wistia.com/blog/startup-ceo-makes-videos)
- External URL-s should open in new window :snail:
- Newsletter subscribe
- Offer free download
- Exit modal or Hijack box: *coupon, free download, blog notification, newsletter* etc.
- Background: http://www.aqua.hu/files/pix-background/nv-gf-gtx-heroesofthestormgeneric-skin2-hun.jpg
- Sharing: https://www.addthis.com/ https://www.po.st/ http://www.sharethis.com/ :snail:
- Content to share: https://paper.li/
- A/B testing - Google Optimize, Optimonk

### Code styling

- UTF-8 encoding (no BOM)
- Line ends
- Indentation
- Trailing spaces `sed -i -e 's|\s\+$||' file.ext`

### Theme and plugin check

1. Theme meta and version in `style.css`
1. `query-monitor` errors and warnings
1. `theme-check` and http://themecheck.org/
1. `vip-scanner`
1. Frontend Debugger with `?remove-scripts`
1. `p3-profiler`
1. https://validator.w3.org/ :snail:
1. https://validator.nu/

#### Typical theme and plugin errors

- Dynamic page parts (e.g. rotating quotes by PHP)
- Dynamically generated resources `style.css.php` (fix: `grep -E "(register|enqueue).*\.php"`)
- New WordPress entry point (fix: `grep -E "\b(require|include).*wp-"`)
- Missing theme meta tags in `style.css`
- Missing resource version in `grep -E "wp_(register|enqueue)_.*\("` calls
- Script/style printing (instead of using `wp_localize_script(); wp_add_inline_script(); wp_add_inline_style();`
- Always requiring admin code (fix: `whats-running`)
- Lack of `grep -E "\\\$_(GET|POST)"` sanitization
- Missing *nonce* on input
- PHP short opentags (fix: `grep -F "<?="`)
- PHP errors, deprecated WP code (fix: `define( 'WP_DEBUG', true );`)
- Lack of permissions for WP editors
- Non-200 HTTP responses
- Extra server-side requests: HTTP, DNS, file access
- Independent e-mail sending (fix: `grep -E "\b(wp_)?mail\("`)
- Proprietary install/update (fix: disable TGM-Plugin-Activation)
- Home call, external URL-s (fix: search for URL-s, use Snitch plugin and `tcpdump`)
- Form field for file upload `<input type="file" />`
- Insufficient or excessive font character sets (fix: `&subset=latin,latin-ext`)
- `@font-face` formats: eof, woff2, woff, ttf, svg; position: top of first CSS
- [BOM](https://en.wikipedia.org/wiki/Byte_order_mark) (fix: `sed -ne '1s/\xEF\xBB\xBF/BOM!!!/p'`)
- Characters before `<!DOCTYPE html>`
- JavaScript code parsable - by dummy crawlers - as HTML (`<a>` `<iframe>` `<script>`)
- Page loading overlay, display content by JavaScript causing [FOUC](https://en.wikipedia.org/wiki/Flash_of_unstyled_content)
- Unnecessary Firefox caret
- [Mobile views](https://webmasters.googleblog.com/2016/11/mobile-first-indexing.html) (responsive design)
- Confusion in colors: normal text color, link and call2action color, accent color
- Email header and content check https://www.mail-tester.com/

### Duplicate content

- www -> non-www redirection
- Custom subdomain with same content
- Development domains
- Early access domain by the hosting company (`cpanel.server.com/~user`, `somename.hosting.com/`)
- Access by IP address (`http://1.2.3.4/`)

### 404 page

- Informative :snail:
- Cooperative (search form, automatic suggestions, Google's fixurl.js) :snail:
- Attractive
- [Adaptive Content Type for 404-s](https://github.com/szepeviktor/wordpress-plugin-construction/blob/master/404-adaptive-wp.php)
- [404 pages on AWWWARDS](http://www.awwwards.com/inspiration/search?text=404)

### Resource optimization

- Image format `convert PNG --quality 100 JPG`
- Image name `mv DSC-0005.JPG prefix-descriptive-name.jpg`
- Image optimization `jpeg-recompress JPG OPTI_JPG` :snail:
- [Self-host Google Fonts](https://google-webfonts-helper.herokuapp.com/)
- JavaScript, CSS concatenation, minification `cat small_1.css small_2.css > large.css`
- Conditional, lazy or late loading (slider, map, facebook content, image gallery)
- Use [async and defer](http://www.growingwiththeweb.com/2014/02/async-vs-defer-attributes.html) for JavaScripts
- Light loading, e.g. `&controls=2` for YouTube
- HTTP/2 server push
- [DNS Prefetch, Preconnect, Prefetch, Prerender](http://w3c.github.io/resource-hints/#resource-hints)
- YouTube custom video thumbnail (Full HD)

### HTTP

- HTTP methods `GET POST HEAD` and `OPTIONS PUT DELETE TRACE` etc.
- https://redbot.org/
- Loading in IFRAME (Google translate, Facebook app)
- https://securityheaders.io/ and see [Twitter's list](https://github.com/twitter/secureheaders/blob/master/README.md)
- https://report-uri.io/home/tools CSP, HKPK, SRI etc.
- https://www.webpagetest.org/
- https://speedcurve.com/
- https://insites.com/
- Does the website have a public API? (WP REST API, WooCommerce API)
- Test (REST) API [Postman](https://chrome.google.com/webstore/detail/postman/fhbjgbiflinjbdggehcddcbncdddomop)

### PHP errors

wp-config.php: `define( 'WP_DEBUG', true );`

```bash
tail -f /var/log/apache2/SITE_USER-error.log | sed -e 's|\\n|\n●|g'
```

### SEO

- `blog_public` and robots.txt :snail:
- XML sitemaps with link from robots.txt :snail:
- Page title (blue in SERP) :snail:
- Permalink structure and slug optimization (green in [SERP](https://en.wikipedia.org/wiki/Search_engine_results_page)) :snail:
- Page meta description (grey in SERP) :snail:
- Headings: H1, H2 / H3-H6
- Images: `alt`, `title`
- Breadcrumbs
- [Content keyword density](https://www.seoquake.com/)
- [noarchive?](https://support.google.com/webmasters/answer/79812)
- Multilingual site (`hreflang` attribute)
- Structured data https://schema.org/ http://microformats.org/
- [Google My Business](https://www.google.com/business/) :snail:
- [SERPs Google Location Changer](https://serps.com/tools/google-search-location)
- http://backlinko.com/google-ranking-factors
- AdWords campaign as a SEO factor
- [SEO for startups :play_or_pause_button:](https://www.youtube.com/watch?v=El3IZFGERbM)
- [Growthery](http://thepitch.hu/seo-ugynokseg/) (HU)

### Legal (EN)

- Privacy policy :snail:
- [Cookie Consent Kit](http://ec.europa.eu/ipg/basics/legal/cookies/index_en.htm#section_4) + opt out,
  [cookie notice template](http://ec.europa.eu/ipg/docs/cookie-notice-template.zip),
  [Cookie Consent wizard by Insites](https://cookieconsent.insites.com/download/),
  [EDAA Glossary](http://www.youronlinechoices.com/hu/szomagyarazat)
- Terms & Conditions
- *Operated by*, *Hosted at*
- `/.well-known/dnt-policy.txt`

### Jogi dolgok (HU)

- Adatkezelési tájékoztató (cookie nyilatkozat, üzemeltető neve) :snail:
- Impresszum (csak űrlaphoz kell)
- [ÁSZF](https://net-jog.hu/kapcsolat/) (vásárláshoz)
- Ingyenes [NAIH nyilvántartásba vétel](https://www.naih.hu/bejelentkezes.html) (hírlevél küldéshez)
- EU General Data Protection Regulation (GDPR, 2018. május 25-től)

### Compatiblitity

- [\<head> cheatsheet](http://gethead.info/)
- Text selection: color+background-color, disable selection
- Keyboard-only navigation (tabbing, [skip navigation](https://webaim.org/techniques/skipnav/)) :snail:
- Toolbar color of Chrome for Android (`theme-color` meta) :snail:
- [Windows 8 and 10 tiles](http://www.buildmypinnedsite.com/)
- Skype IE Add-on `<meta name="SKYPE_TOOLBAR" content="SKYPE_TOOLBAR_PARSER_COMPATIBLE">`
- OpenGraph for [Facebook](https://developers.facebook.com/docs/reference/opengraph) and [Twitter](https://dev.twitter.com/cards/markup) :snail:
- Emojis (entering, storing, displaying)
- [Printer](http://www.printfriendly.com/), [Gutenberg framework](https://github.com/BafS/Gutenberg)
- [Accessibility attributes](https://www.w3.org/TR/wai-aria/states_and_properties) for screen readers
- [Accessibility Guidelines](https://www.w3.org/TR/WCAG20/)
- Microsoft/Libre Office (copy-and-paste content or open URL)
- Adblock and filter lists (Adblock Plus, uBlock Origin, Disconnect, Ghostery)
- Reader mode (from Firefox `chrome://global/skin/aboutReaderContent.css`)

### Integration (3rd party services)

Document in `hosting.yml` and check functionality.

- Certificate Authority (OCSP servers for obtaining SSL certificate revocation status)
- A/B testing
- External search
- External resources (fonts)
- Social media ([Twitter card](https://cards-dev.twitter.com/validator))
- Video
- Maps
- Widgets
- Tracking codes (make *UA-number* `'UN'+'parse'+'able'`)
- Advertisement
- Live chat
- Newsletter subscription
- Payment gateway
- CDN

### Tracking

Gain access, set up and test.

- Google Analytics, Google Tag Manager :snail:
- Facebook Pixel
- Piwik
- Clicktale
- Smartlook
- Hotjar
- URL shortening: Link tracking, Download tracking

### Last checks

- Basic site functionality :snail:
- Registration :snail:
- Purchase :snail:
- Contact forms :snail:


## Monitor


See [/monitoring/README.md](/monitoring/README.md)

Uptime ([pingdom.com](https://www.pingdom.com/), [hetrixtools.com](https://hetrixtools.com/), [selectel.com](https://selectel.com/services/additional/monitoring/)) :snail:

[List of all errors in Apache httpd](https://wiki.apache.org/httpd/ListOfErrors)

@TODO Report JavaScript errors

- https://bugsnag.com/
- Piwik
- Google Analytics
- Report to `/js-error.php`
- http://jserrlog.appspot.com/
- https://github.com/mperdeck/jsnlog.js
- https://developers.google.com/analytics/devguides/collection/analyticsjs/exceptions
- https://github.com/errbit/errbit
- https://github.com/airbrake/airbrake-js


## Backup


1. Database
1. Files
1. Settings (connected 3rd party services)
1. Authentication data


## Uninstallation


- Archive for long term
- Monitoring
- Backups
- DNS records
- PHP-FPM pool
- DB, DB user
- Webserver vhost, add placeholder page
- Revoke SSL certificates
- Fail2ban `logpath`
- Webserver logs
- Files
- Linux user
- Email accounts
- External resources (3rd party services)
- [Google Search Console](https://www.google.com/webmasters/tools/url-removal)



### Maintenance :wrench:

Have me on board: viktor@szepe.net
