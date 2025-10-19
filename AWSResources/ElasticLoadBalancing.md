Type: AWS::ElasticLoadBalancing::LoadBalancer
Properties:
  AccessLoggingPolicy: 
    AccessLoggingPolicy
  AppCookieStickinessPolicy: 
    - AppCookieStickinessPolicy
  AvailabilityZones: 
    - String
  ConnectionDrainingPolicy: 
    ConnectionDrainingPolicy
  ConnectionSettings: 
    ConnectionSettings
  CrossZone: Boolean
  HealthCheck: 
    HealthCheck
  Instances: 
    - String
  LBCookieStickinessPolicy: 
    - LBCookieStickinessPolicy
  Listeners: 
    - Listeners
  LoadBalancerName: String
  Policies: 
    - Policies
  Scheme: String
  SecurityGroups: 
    - String
  Subnets: 
    - String
  Tags: 
    - Tag
