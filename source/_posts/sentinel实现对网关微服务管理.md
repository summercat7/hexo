---
title: sentinel实现对网关微服务管理
date: 2020-12-04 14:48:20
categories: java
tags: 框架
---

## Sentinel 通过 nacos 对 Spring Cloud Gateway 持久化管理

### 客户端使用时需引入以下模块（以 Maven 为例）：

```xml

		<dependency>
			<groupId>com.alibaba.csp</groupId>
			<artifactId>sentinel-transport-simple-http</artifactId>
		</dependency>

		<dependency>
			<groupId>com.alibaba.cloud</groupId>
			<artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
			<version>2.1.1.RELEASE</version>
		</dependency>

		<dependency>
			<groupId>com.alibaba.cloud</groupId>
			<artifactId>spring-cloud-alibaba-sentinel-gateway</artifactId>
			<version>2.1.1.RELEASE</version>
		</dependency>
        <!-- Sentinel扩展Nacos数据源的依赖 -->
		<dependency>
			<groupId>com.alibaba.csp</groupId>
			<artifactId>sentinel-datasource-nacos</artifactId>
		</dependency>
```

### 客户端配置文件：

```yaml
spring:
  cloud:
    # 读取向nacos注册的微服务
    nacos:
      discovery:
        server-addr: 127.0.0.1:8848
      #  namespace: c0e306f9-a808-4b03-b40f-e9f2f2ded91c
    # sentinel 配置
    sentinel:
      transport:
        dashboard: 127.0.0.1:8081
      # 规则文件的nacos地址、命名空间、组名
      nacos:
        server-addr: 127.0.0.1:8848
        namespace: d3c1787a-4bd0-4d8b-98e6-6bf38672acfa
        groupId: SENTINEL_GROUP
      datasource:
        # 名称随意
        gw-api-group:
          nacos:
            server-addr: ${spring.cloud.sentinel.nacos.server-addr}
            namespace: ${spring.cloud.sentinel.nacos.namespace}
            dataId: ${spring.application.name}-gw-api-group-rules
            groupId: ${spring.cloud.sentinel.nacos.groupId}
            # 规则类型，取值见：
            # org.springframework.cloud.alibaba.sentinel.datasource.RuleType
            rule-type: gw-api-group
        gw-flow:
          nacos:
            server-addr: ${spring.cloud.sentinel.nacos.server-addr}
            namespace: ${spring.cloud.sentinel.nacos.namespace}
            dataId: ${spring.application.name}-gw-flow-rules
            groupId: ${spring.cloud.sentinel.nacos.groupId}
            rule-type: gw-flow
        flow:
          nacos:
            server-addr: ${spring.cloud.sentinel.nacos.server-addr}
            dataId: ${spring.application.name}-flow-rules
            namespace: ${spring.cloud.sentinel.nacos.namespace}
            groupId: ${spring.cloud.sentinel.nacos.groupId}
            # 规则类型，取值见：
            # org.springframework.cloud.alibaba.sentinel.datasource.RuleType
            rule-type: flow
        degrade:
          nacos:
            server-addr: ${spring.cloud.sentinel.nacos.server-addr}
            namespace: ${spring.cloud.sentinel.nacos.namespace}
            dataId: ${spring.application.name}-degrade-rules
            groupId: ${spring.cloud.sentinel.nacos.groupId}
            rule-type: degrade
        system:
          nacos:
            server-addr: ${spring.cloud.sentinel.nacos.server-addr}
            namespace: ${spring.cloud.sentinel.nacos.namespace}
            dataId: ${spring.application.name}-system-rules
            groupId: ${spring.cloud.sentinel.nacos.groupId}
            rule-type: system
        authority:
          nacos:
            server-addr: ${spring.cloud.sentinel.nacos.server-addr}
            namespace: ${spring.cloud.sentinel.nacos.namespace}
            dataId: ${spring.application.name}-authority-rules
            groupId: ${spring.cloud.sentinel.nacos.groupId}
            rule-type: authority
        param-flow:
          nacos:
            server-addr: ${spring.cloud.sentinel.nacos.server-addr}
            namespace: ${spring.cloud.sentinel.nacos.namespace}
            dataId: ${spring.application.name}-param-flow-rules
            groupId: ${spring.cloud.sentinel.nacos.groupId}
            rule-type: param-flow
      # 限流返回的响应
      scg:
        fallback:
          mode: response
          response-status: 455
          response-body: 服务器繁忙，请稍后再试！
      eager: true
```

### Sentinel控制台改造：

控制台改造主要是为规则实现

- DynamicRuleProvider：从Nacos上读取配置
- DynamicRulePublisher：将规则推送到Nacos上

1、修改pom.xml，找到将 <scope>test</scope> 这一行注释掉，即改为如下：

```xml
<dependency>
  <groupId>com.alibaba.csp</groupId>
  <artifactId>sentinel-datasource-nacos</artifactId>
  <!--<scope>test</scope>-->
</dependency>
```

2、找到 `sentinel-dashboard/src/test/java/com/alibaba/csp/sentinel/dashboard/rule/nacos`目录，将整个目录拷贝到 `sentinel-dashboard/src/main/java/com/alibaba/csp/sentinel/dashboard/rule/nacos`

3、 修改 `com.alibaba.csp.sentinel.dashboard.controller.v2.FlowControllerV2` ，修改为：

```java
@Autowired
@Qualifier("flowRuleNacosProvider")
private DynamicRuleProvider<List<FlowRuleEntity>> ruleProvider;
@Autowired
@Qualifier("flowRuleNacosPublisher")
private DynamicRulePublisher<List<FlowRuleEntity>> rulePublisher;

```

4、 修改 `sentinel-dashboard/src/main/webapp/resources/app/scripts/directives/sidebar/sidebar.html`，解开注解：

```html
<li ui-sref-active="active">
  <a ui-sref="dashboard.flow({app: entry.app})">
    <i class="glyphicon glyphicon-filter"></i>&nbsp;&nbsp;流控规则 V1</a>
</li>

```

其他功能若要实现持久化，需要自己实现相关的DynamicRuleProvider和DynamicRulePublisher，相应代码已存本博客对应的文件夹中。本博客参考以下官方damo。



## Spring Cloud Gateway

从 1.6.0 版本开始，Sentinel 提供了 Spring Cloud Gateway 的适配模块，可以提供两种资源维度的限流：

- route 维度：即在 Spring 配置文件中配置的路由条目，资源名为对应的 routeId
- 自定义 API 维度：用户可以利用 Sentinel 提供的 API 来自定义一些 API 分组

使用时需引入以下模块（以 Maven 为例）：

```xml
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-spring-cloud-gateway-adapter</artifactId>
    <version>x.y.z</version>
</dependency>
```

使用时只需注入对应的 `SentinelGatewayFilter` 实例以及 `SentinelGatewayBlockExceptionHandler` 实例即可。比如：

```java
@Configuration
public class GatewayConfiguration {

    private final List<ViewResolver> viewResolvers;
    private final ServerCodecConfigurer serverCodecConfigurer;

    public GatewayConfiguration(ObjectProvider<List<ViewResolver>> viewResolversProvider,
                                ServerCodecConfigurer serverCodecConfigurer) {
        this.viewResolvers = viewResolversProvider.getIfAvailable(Collections::emptyList);
        this.serverCodecConfigurer = serverCodecConfigurer;
    }

    @Bean
    @Order(Ordered.HIGHEST_PRECEDENCE)
    public SentinelGatewayBlockExceptionHandler sentinelGatewayBlockExceptionHandler() {
        // Register the block exception handler for Spring Cloud Gateway.
        return new SentinelGatewayBlockExceptionHandler(viewResolvers, serverCodecConfigurer);
    }

    @Bean
    @Order(Ordered.HIGHEST_PRECEDENCE)
    public GlobalFilter sentinelGatewayFilter() {
        return new SentinelGatewayFilter();
    }
}
```

Demo 示例：[sentinel-demo-spring-cloud-gateway](https://github.com/alibaba/Sentinel/tree/master/sentinel-demo/sentinel-demo-spring-cloud-gateway)

比如我们在 Spring Cloud Gateway 中配置了以下路由：

```yaml
server:
  port: 8090
spring:
  application:
    name: spring-cloud-gateway
  cloud:
    gateway:
      enabled: true
      discovery:
        locator:
          lower-case-service-id: true
      routes:
        # Add your routes here.
        - id: product_route
          uri: lb://product
          predicates:
            - Path=/product/**
        - id: httpbin_route
          uri: https://httpbin.org
          predicates:
            - Path=/httpbin/**
          filters:
            - RewritePath=/httpbin/(?<segment>.*), /$\{segment}
```

同时自定义了一些 API 分组：

```java
private void initCustomizedApis() {
    Set<ApiDefinition> definitions = new HashSet<>();
    ApiDefinition api1 = new ApiDefinition("some_customized_api")
        .setPredicateItems(new HashSet<ApiPredicateItem>() {{
            add(new ApiPathPredicateItem().setPattern("/product/baz"));
            add(new ApiPathPredicateItem().setPattern("/product/foo/**")
                .setMatchStrategy(SentinelGatewayConstants.URL_MATCH_STRATEGY_PREFIX));
        }});
    ApiDefinition api2 = new ApiDefinition("another_customized_api")
        .setPredicateItems(new HashSet<ApiPredicateItem>() {{
            add(new ApiPathPredicateItem().setPattern("/ahas"));
        }});
    definitions.add(api1);
    definitions.add(api2);
    GatewayApiDefinitionManager.loadApiDefinitions(definitions);
}
```

那么这里面的 route ID（如 `product_route`）和 API name（如 `some_customized_api`）都会被标识为 Sentinel 的资源。比如访问网关的 URL 为 `http://localhost:8090/product/foo/22` 的时候，对应的统计会加到 `product_route` 和 `some_customized_api` 这两个资源上面，而 `http://localhost:8090/httpbin/json` 只会对应到 `httpbin_route` 资源上面。

您可以在 `GatewayCallbackManager` 注册回调进行定制：

- `setBlockHandler`：注册函数用于实现自定义的逻辑处理被限流的请求，对应接口为 `BlockRequestHandler`。默认实现为 `DefaultBlockRequestHandler`，当被限流时会返回类似于下面的错误信息：`Blocked by Sentinel: FlowException`。



## 客户端接入控制台

控制台启动后，客户端需要按照以下步骤接入到控制台。

### 1 引入JAR包

客户端需要引入 Transport 模块来与 Sentinel 控制台进行通信。您可以通过 `pom.xml` 引入 JAR 包:

```xml
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-transport-simple-http</artifactId>
    <version>x.y.z</version>
</dependency>
```

### 2 配置启动参数

启动时加入 JVM 参数 `-Dcsp.sentinel.dashboard.server=consoleIp:port` 指定控制台地址和端口。若启动多个应用，则需要通过 `-Dcsp.sentinel.api.port=xxxx` 指定客户端监控 API 的端口（默认是 8719）。

从 1.6.3 版本开始，控制台支持网关流控规则管理。您需要在接入端添加 `-Dcsp.sentinel.app.type=1` 启动参数以将您的服务标记为 API Gateway，在接入控制台时您的服务会自动注册为网关类型，然后您即可在控制台配置网关规则和 API 分组。

除了修改 JVM 参数，也可以通过配置文件取得同样的效果。更详细的信息可以参考 [启动配置项](https://github.com/alibaba/Sentinel/wiki/启动配置项)。



## API Gateway 适配

Sentinel 支持对 Spring Cloud Gateway、Zuul 等主流的 API Gateway 进行限流。

### Spring Cloud Gateway

从 1.6.0 版本开始，Sentinel 提供了 Spring Cloud Gateway 的适配模块，可以提供两种资源维度的限流：

- route 维度：即在 Spring 配置文件中配置的路由条目，资源名为对应的 routeId
- 自定义 API 维度：用户可以利用 Sentinel 提供的 API 来自定义一些 API 分组

使用时需引入以下模块（以 Maven 为例）：

```xml
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-spring-cloud-gateway-adapter</artifactId>
    <version>x.y.z</version>
</dependency>
```

使用时只需注入对应的 `SentinelGatewayFilter` 实例以及 `SentinelGatewayBlockExceptionHandler` 实例即可。比如：

```java
@Configuration
public class GatewayConfiguration {

    private final List<ViewResolver> viewResolvers;
    private final ServerCodecConfigurer serverCodecConfigurer;

    public GatewayConfiguration(ObjectProvider<List<ViewResolver>> viewResolversProvider,
                                ServerCodecConfigurer serverCodecConfigurer) {
        this.viewResolvers = viewResolversProvider.getIfAvailable(Collections::emptyList);
        this.serverCodecConfigurer = serverCodecConfigurer;
    }

    @Bean
    @Order(Ordered.HIGHEST_PRECEDENCE)
    public SentinelGatewayBlockExceptionHandler sentinelGatewayBlockExceptionHandler() {
        // Register the block exception handler for Spring Cloud Gateway.
        return new SentinelGatewayBlockExceptionHandler(viewResolvers, serverCodecConfigurer);
    }

    @Bean
    @Order(-1)
    public GlobalFilter sentinelGatewayFilter() {
        return new SentinelGatewayFilter();
    }
}
```

Demo 示例：[sentinel-demo-spring-cloud-gateway](https://github.com/alibaba/Sentinel/tree/master/sentinel-demo/sentinel-demo-spring-cloud-gateway)