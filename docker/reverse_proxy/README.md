# Reverse Proxy Setup

This part of the collection can be used to setup a reverse proxy.
My personal choice for reverse proxies is Traefik since it was specially designed for this purpose.
The configuration is simple but offers enough options for more complex applications.
The integrated ACME functionality is also very easy to configure.

In my setup I enable the API functionality which provides us with a dashboard for a good overview of the active backend services which we are routing to.
This comes with the problem that Traefik doesn't generate certificates for its own services by default.
To overcome this, we label the Traefik service itself to be a Traefik backend.
This makes Traefik generate a certificate for itself.
To at least get one layer of security for the dashboard, we use basic HTTP authentication using an *.htaccess* file.
The workaround used here is inspired by this [blog post](https://medium.com/@xavier.priour/secure-traefik-dashboard-with-https-and-password-in-docker-5b657e2aa15f).

Setup steps:
1. After cloning first change the rights of the `acme.json` file with `chmod 600 acme.json`.
The `acme.json` file is the "certificate storage" that we'll mount from the host system to the docker container.
2. Generate an md5 login in the form *user:md5hash* (for example using this [generator](http://www.htaccesstools.com/htpasswd-generator/)) and put it in the `.htaccess` file.
3. Update the `treafik.toml` file with an appropriate E-Mail address
4. Change the `traefik.frontend.rule` of the Traefik service in the `docker-compose.yaml` file to match your domain/subdomain.
5. Start the container using `docker-compose up -d`
6. To add backend services which you want to route to, simply label them appropriately and don't forget to attach them to the created *docker network*.
A detailed description of the labels can be found on the [Traefik Docs](https://docs.traefik.io/configuration/backends/docker/#on-containers)
