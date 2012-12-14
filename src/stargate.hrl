-compile([{parse_transform, lager_transform}]).

-define(UPLOAD_DATA_PREFIX, "/opt/data/").
-define(DOWNLOAD_DATA_PREFIX, "/data/").
%-include("../deps/cowboy/include/http.hrl").

-record(token,
{
	  app_id				%% app_id equal to service_id
	, app_name				%% it's from app_id
    , option_type			%% upload or download
    , create_time			%% token's create time 
    , user_id
    , user_ip				%% client request ip
    , resource_id			%% rid
    , resource_type
    , resource_size
	, resource_name
    , expiration			%% token expire time
    , etag					%% how to use it?
}).

%% ++---------------------------------------------
%% serve_file
%% -----------------------------------------------
-define(READ_SIZE, 256*1024).
-define(MAX_CHUNK_LENGTH, 256*1024).


%% ++---------------------------------------------
%% fsream
%% -----------------------------------------------
-define(READ_AHEAD_SIZE,  256*1024).
-define(DELAY_WRITE_SIZE, 256*1024).
-define(DELAY_WRITE_TIME, 1000).


%% ++---------------------------------------------
%% sg_udp_server 
%% -----------------------------------------------
-define(UDP_SERVER_PORT, 9999).
-define(UDP_SERVER_OPTION, [binary, inet]).


%% ++---------------------------------------------
%% sg_udp_server 
%% -----------------------------------------------
-define(TCP_SERVER_HOST, "0.0.0.0").
-define(TCP_SERVER_PORT, 8888).
