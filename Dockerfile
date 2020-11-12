# Use latest jboss/base-jdk:11 image as the base
FROM jboss/wildfly

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 21.0.0.Final
ENV WILDFLY_SHA1 0697db2640e87ef1073a374a67d1c14560f6bf74
ENV JBOSS_HOME /opt/jboss/wildfly

# config de conexão com o BD
ENV BD_NAME dbjava
ENV DB_PASS admin
ENV DB_USER admin
ENV DB_HOST 172.20.0.2
ENV DB_PORT 5432

# JNDI
ENV DS_NAME dbjavaDS
ENV JNDI_NAME java:/dbjavaDS

#ADD ./postgresql-42.2.18.jar /tmp/postgresql-42.2.18.jar
ADD ./postgresql-42.2.18.jar /opt/jboss/wildfly/standalone/deployments/

ADD ./scripts/wildfly-config.cli /tmp/wildfly-config.cli


# configurandio e adicionado o datasource no wildfly
RUN /bin/sh -c '$JBOSS_HOME/bin/standalone.sh -c=standalone.xml &' && \
  sleep 10 && \
  cd /tmp && \
  $JBOSS_HOME/bin/jboss-cli.sh --connect --command="module add --name=org.postgresql --resources=/opt/jboss/wildfly/standalone/deployments/postgresql-42.2.18.jar --dependencies=javax.api,javax.transaction.api" && \
  $JBOSS_HOME/bin/jboss-cli.sh --connect --command="/subsystem=datasources/jdbc-driver=postgres:add(driver-name=postgres,driver-module-name=org.postgresql,driver-class-name=org.postgresql.Driver)" && \
  $JBOSS_HOME/bin/jboss-cli.sh --connect --command="data-source add --jndi-name=java:/dbjavaDS --name=dbjavaDS --connection-url=jdbc:postgresql://172.20.0.2:5432/dbjava --driver-name=postgresql-42.2.18.jar --user-name=admin --password=admin" && \
  $JBOSS_HOME/bin/jboss-cli.sh --connect --command=:shutdown


# Deploy da aplicação após a configuração do datasource
ADD ./target/web.war /opt/jboss/wildfly/standalone/deployments/

RUN /opt/jboss/wildfly/bin/add-user.sh admin admin --silent

# Expose the ports we're interested in
EXPOSE 8080 9990

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

