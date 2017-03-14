#!/bin/bash

#. ~/.sshagent >/dev/null 2>&1
CWD=$(dirname $(readlink -f $0))
. $CWD/setenvs


addUser() {
  sudo useradd kafka -m
  sudo passwd kafka
  sudo adduser kafka sudo
  su -kafka
}


installJava() {
  sudo apt-get update
  sudo apt-get install default-jre
}

installZooKeeper() {
  sudo apt-get install zookeeperd
}

startZookeeper() {
  nohup ~/kafka/bin/zookeeper-server-start.sh ~/kafka/config/zookeeper.properties > ~/kafka/zookeeper.log 2>&1 &
}

testZooKeeper() {
  telnet localhost 2181
}

installKafka() {
  echo -e "\tINFO: Kafka install: 'https://kafka.apache.org/quickstart'"
  mkdir -p $HOME/kafka && cd $HOME/kafka
  kafka_file="kafka_2.11-$KAFKA_VERSION.tgz"
  #wget "http://www-eu.apache.org/dist/kafka/$KAFKA_VERSION/$kafka_file"
  #wget "http://mirror.dkm.cz/apache/kafka/$KAFKA_VERSION/$kafka_file"
  tar -xvzf $kafka_file
  rm current
  ln -s ${kafka_file::-4} current
  echo -e "\tINFO: current version: ${kafka_file::-4}"
  ls -la ~/kafka/current/
}

configureKafka() {
  vi ~/kafka/config/server.properties
  # add line
  delete.topic.enable = true
}

startKafka() {
  # Kafka server = Kafka broker as a background process that is independent of your shell session
  nohup ~/kafka/bin/kafka-server-start.sh ~/kafka/config/server.properties > ~/kafka/kafka.log 2>&1 &

  nohup
}

testInstallation() {
  publishMessage
  consumeMessage
}

publishMessage() {
  echo "Hello, World" | ~/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic TutorialTopic > /dev/null
}

consumeMessage() {
  ~/kafka/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic TutorialTopic --from-beginning
}


producer() {
  ~/kafka/bin/kafka-console-producer.sh --broker-list localhost:9992 --topic test
}

consumer() {
  ~/kafka/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic test --from-beginning
}


installKafkaT() {
  sudo apt-get install ruby ruby-dev build-essential
  sudo gem install kafkat --source https://rubygems.org --no-ri --no-rdoc

  # add lines to
  vi ~/.kafkatcfg
  <<EOF
{
  "kafka_path": "~/kafka",
  "log_path": "/tmp/kafka-logs",
  "zk_path": "localhost:2181"
}
EOF
}

runKafkaT() {
  kakat partitions
}

restrictKafkaUser() {
  sudo deluser kafka sudo
  sudo passwd kafka -l    # This makes sure that nobody can directly log into it.
  # sudo passwd kafka -u  # if you want to unlock it
}


KAFKA_VERSION="0.10.2.0"
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "#------------------------------------------------------------------------"
      echo "#  Kafka"
      echo "#------------------------------------------------------------------------"
      echo -e "\t-c  |--check                check kafka"
      echo -e "\t-ik |--install_kafka        intall Kafka"
      echo -e "\t-h  |--help                 show help"
      exit 0
      ;;
    -ik|--install_kafka)
      installKafka
      ;;
    *)
      break
      ;;
  esac
  exit 0
done


