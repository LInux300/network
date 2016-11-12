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
  # download and extract binaries
  mkdir -p ~/Downloads
  #wget "http://mirror.cc.columbia.edu/pub/software/apache/kafka/0.8.2.1/kafka_2.11-0.8.2.1.tgz" -O ~/Downloads/kafka.tgz
  wget "http://apache.miloslavbrada.cz/kafka/0.10.1.0/kafka-0.10.1.0-src.tgz" -O ~/Downloads/kafka.tgz
  mkdir -p ~/kafka && cd ~/kafka
  tar -xvzf ~/Downloads/kafka.tgz --strip 1

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


while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo "#------------------------------------------------------------------------"
            echo "#  Kafka"
            echo "#------------------------------------------------------------------------"
            echo "options:"
            echo "-c,  --check                check kafka"
            echo "-h,  --help                 show help"
            exit 0
            ;;
        -r|--check)
            ;;
        *)
            break
            ;;
    esac
    exit 0
done


