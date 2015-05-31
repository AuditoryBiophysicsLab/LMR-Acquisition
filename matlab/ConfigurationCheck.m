function result = ConfigurationCheck()
    %% ensure that everything's on the path
    path(path,genpath(pwd));
    %% test database connectivity
    MongoStart();
    m=Mongo('roundwindow.ad.bu.edu');
    assert(m.checkConnection==1,'Connection to Roundwindow could not be established');
    clear m;
    MongoStop();
    result = 1;
end