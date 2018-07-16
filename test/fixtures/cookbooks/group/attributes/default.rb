default[:netdev][:services] = [%w[ftp], %w[ssh], %w[netconf ssh]]
default[:netdev][:bgp] = { 'internal' => { 'type' => 'internal', 'neighbor' => ['10.10.10.10', '10.10.10.11'], 'local-address' => '20.20.20.20', 'peer-as' => '100' },
                           'external' => { 'type' => 'external', 'neighbor' => ['30.30.10.10', '30.30.10.11'], 'local-address' => '20.20.20.20', 'peer-as' => '200' } }

default[:netdev][:syslog] = { 'messages' => [{ 'facility' => 'any', 'level' => 'critical' }, { 'facility' => 'authorization', 'level' => 'info' }],
                              'interactive-commands' => [{ 'facility' => 'interactive-commands', 'level' => 'error' }] }
