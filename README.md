#StarGate - A General TCP transparent Proxy 

## A TCP transparent Proxy which use poolboy manage connects and use ranch receive request.

## Usage
```erl-sh
[root@blackanimal workbench]# wget http://meet.xpro.im/stargate/stargate.tar.gz
[root@blackanimal workbench]# tar -zxvf stargate.tar.gz
[root@blackanimal workbench]# cd stargate
[root@blackanimal workbench]# cd etc
[root@blackanimal stargate]# cp pool.config.example pool.config
```

then modify config
```
{memcache, {listen, 8605}, {handler, raw_tcp_handler},
    [
          {
            [{size, 1}, {max_overflow, 20}]
          , [{host, {10,58,41,59}}, {port, 11211}]
        }
    ]
}.
```


## Custom Develop

1. install erlang first

2. clone this reop to your workbench

3. entry ***src*** directory 

4. if you want another protocol handler, write it into the ***handler*** directory

