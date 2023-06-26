# Minecraft Server

## Third Party Software

### [Paper MC Docs](https://docs.papermc.io/)

### [Paper MC Getting Started](https://docs.papermc.io/paper/cat/admin/getting-started)

### [Plugins](https://hangar.papermc.io/)

### [Optimizing Minecraft](https://github.com/YouHaveTrouble/minecraft-optimization/blob/1.20/README.md)
---
To start the server, you must accept the EULA by setting an environment variable `EULA` to `TRUE`.

To use the default settings, you don't need to mount any volumes. However, if you want to change the default settings, you need to mount a volume to `/config`. Make sure that the name of the settings file you want to override is exactly the same as the name of the file you want to change. For example, if you want to change the `server.properties` file, you should name the new file `server.properties` in the config directory; otherwise, the new file won't be used. If you need examples of the default settings, mount a volume to `/config` and run the container once. The default settings will be copied to the volume.

To use your own worlds, you must mount a volume to the following directories: `/minecraft/world`, `/minecraft/world_nether`, and `/minecraft/world_the_end`.

It is recommended to mount a volume to `/minecraft` to ensure that the server data is persistent.

In order to add plugins, you must mount a volume to `/minecraft/plugins` and place the plugins in that directory. The plugins must be in the form of a `.jar` file. Some plugins are distributed as a `.zip` file. In that case, you must extract the `.jar` file from the `.zip` file and place it in the plugins directory.

If you are interested in using a proxy refer to my [Docker Minecraft Proxy Repository](https://github.com/RedactDigital/docker-minecraft-proxy) which utilizes the velocity proxy created by [Paper MC](https://papermc.io/)

## Example `docker-compose.yml`

```yaml
version: '3.9'
services:
  minecraft-server:
    image: ghcr.io/redactdigital/docker-minecraft-server:latest
    container_name: minecraft-server
    restart: unless-stopped
    ports:
      - '25565:25565'
    volumes:
      - minecraft-server:/minecraft
      - ./config:/config
      - ./plugins:/minecraft/plugins
      - ./custom-world:/minecraft/world
      - ./custom-world-nether:/minecraft/world_nether
      - ./custom-world-the-end:/minecraft/world_the_end
    environment:
      EULA: 'true'

volumes:
  minecraft-server:
```

## Example `docker run` command

```bash
docker run -d \
  --name=minecraft-server \
  -p 25565:25565 \
  -v minecraft-server:/minecraft \
  -v ./config:/config \
  -v ./plugins:/minecraft/plugins \
  -v ./custom-world:/minecraft/world \
  -v ./custom-world-nether:/minecraft/world_nether \
  -v ./custom-world-the-end:/minecraft/world_the_end \
  -e EULA='true' \
  ghcr.io/redactdigital/docker-minecraft-server:latest
```
