require 'twitter'
require 'kafka'
require 'date'

class GunclocksController < ApplicationController

  def index
#    @gunclocks = Gunclock.all
#    @gunclocks = Gunclock.order(:id).page(params[:page])
    @gunclocks = Gunclock.order(id: :desc).page(params[:page])
  end

  def show
    @gunclock = Gunclock.find_by(:id => params[:id])
  end

  def edit
    @gunclock = Gunclock.find_by(:id => params[:id])
  end

  def new
    @gunclocks = Gunclock.all
  end

  def create
    @gunclock = Gunclock.new
    @gunclock.size = params[:gunclock][:size]
    @gunclock.color = params[:gunclock][:color]
    @gunclock.save
    redirect_to '/gunclocks/index'
  end

  def update
    @gunclock = Gunclock.find(params[:id])
    @gunclock.size = params[:gunclock][:size]
    @gunclock.color = params[:gunclock][:color]
    @gunclock.save
    redirect_to '/gunclocks/index'

#    if @gunclock.update(gunclock_params)
#    if @gunclock.update(params[:gunclock])
#      redirect_to gunclock_url(@gunclock)
#    else
#      render 'edit'
#    end
  end

  def destroy
    @gunclock = Gunclock.find_by(:id => params[:id])
    @gunclock.destroy
    redirect_to '/gunclocks/index'
  end

  #GET /gunclocks/api/index.:format
  def api_index
#    gunclocks = Gunclock.order(:id)
#    gunclocks = Gunclock.all
    gunclocks = Gunclock.order(id: :desc)
    respond_to do |format|
      format.xml { render :xml => create_xml(gunclocks) }
      format.json { render :json => create_json(gunclocks) }
    end
  end

  #http://ntaku.hateblo.jp/entry/20100911/1284193050
  def api_show
    gunclock = Gunclock.find_by(:id => params[:id])
    respond_to do |format|
      format.xml { render :xml => create_xml_single(gunclock) }
      format.json { render :json => create_json_single(gunclock) }
    end
  end

  #http://ntaku.hateblo.jp/entry/20100911/1284193050
  #for both gunclocks[Array] and gunclock[unit]
  def create_json(gunclocks)
#    gunclocks = [gunclocks] unless gunclocks.class == Array #for 1 gunclock

#    gunclocks = gunclocks.inject([]){ |arr, gunclock|
#      arr << {
#        :id => gunclock.id,
#        :size => gunclock.size,
#        :color => gunclock.color,
#        :created_at => gunclock.created_at
#      }; arr
#    }
#    { :gunclocks => gunclocks }.to_json

#    p gunclocks
    gs = []
    gunclocks.each do |gunclock|
      p gunclock
      gs << {
        :id => gunclock.id,
        :size => gunclock.size,
        :color => gunclock.color,
        :created_at => gunclock.created_at
      }
    end
    { :gunclocks => gs }.to_json

  end

  def create_xml(gunclocks)
#    gunclocks = [gunclocks] unless gunclocks.class == Array
    xml = build_xml do |xml|
      xml.gunclocks {
        gunclocks.each do |gunclock|
          xml.gunclock(:id => gunclock.id) {
            xml.size(gunclock.size)
            xml.color(gunclock.color)
            xml.created_at(gunclock.created_at)
          }
        end
      }
    end
  end

  require File.dirname(__FILE__) + "/GunClock"


  def create_json_single(gunclock)

    gunClock = GunClock.new(gunclock.size.to_i)
    gunClockString = gunClock.toString()

    gs = []
      gs << {
        :id => gunclock.id,
        :size => gunclock.size,
        :color => gunclock.color,
        :created_at => gunclock.created_at,
        :gunClockString => gunClockString
      }
    { :gunclocks => gs }.to_json

  end

  def create_xml_single(gunclock)

    gunClock = GunClock.new(gunclock.size.to_i)
    gunClockString = gunClock.toString()

    xml = build_xml do |xml|
      xml.gunclocks {
          xml.gunclock(:id => gunclock.id) {
            xml.size(gunclock.size)
            xml.color(gunclock.color)
            xml.created_at(gunclock.created_at)
            xml.gunClockString(gunClockString)
          }
      }
    end
  end

  def getGunClock

    p "params[:size]= " 
    p params[:size]

    size = params[:size].present? ? params[:size].to_i : 20

    gunClock = GunClock.new(size)
#    gunClock = GunClock.new(18)
    @gunClockString = gunClock.toString()
    @gunClockColor = params[:color]

  end

  require 'nokogiri'

  def build_xml(&block)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') { |xml| yield(xml) }
    builder.to_xml
  end

  class TweetMessage
    def initialize(message, icon_url)
      @message = message
      @icon_url = icon_url
    end
    attr_accessor :message, :icon_url
  end

  class KafkaMessage
    def initialize(message, topic, offset, partition)
      @message = message
      @topic = topic
      @offset = offset
      @partition = partition
    end
    attr_accessor :message, :topic, :offset, :partition
  end


  def tweetGunclock
    client = Twitter::REST::Client.new do |config|
        config.consumer_key        = "xxxxxxxxxxxxxxxxxxxxxxxx"
        config.consumer_secret     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    end
    @trendWord = ""
    @tweetTrendStrings = []
    client.trends(id=23424856).each do |trend|    #local_trends(id=23424856)も大体同じ
        puts trend.name
        if @trendWord == "" then
            @trendWord = trend.name
        end
        @tweetTrendStrings << trend.name
        if ( @tweetTrendStrings.length == 10 ) then 
           break
        end
    end
    @tweetString = ""
    @tweetStrings = []
    @tweetMessages = []
    result_tweets = client.search(@trendWord)  #take(20)で絞る

    @guessedCurrentTime = "";
    seq = 0
    result_tweets.take(10).each do |tweet|
        seq+=1
        
        seqString = sprintf("%04d", seq)
        tmpString = seqString + "," + tweet.created_at.to_s + "," + tweet.user.screen_name + "," + tweet.text + "\n"
        @tweetString += tmpString
        @tweetStrings << tmpString

        user = client.user(tweet.user.screen_name)
        @tweetMessages << TweetMessage.new(tmpString, user.profile_image_url.to_s)

        if @guessedCurrentTime == "" then
            @guessedCurrentTime = tweet.created_at.in_time_zone('Asia/Tokyo').to_s.sub(/(..:..):../, '\1')
        end

    end
  end

  def tweet
#    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

    client = Twitter::REST::Client.new do |config|
        config.consumer_key        = "xxxxxxxxxxxxxxxxxxxx"
        config.consumer_secret     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# https://teratail.com/questions/4107
# access_tokenを指定しないと、only authentication になって、API制限が増えるらしい
# API回数が増えても、あまりうれしくないかな(180回/15分⇒450回/15分)
#        config.access_token        = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#        config.access_token_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    end

#    brokers = ENV['CLOUDKARAFKA_BROKERS'].split(',')
##    cloudkafka_ca = ENV['CLOUDKARAFKA_CA']
##    cloudkafka_cert = ENV['CLOUDKARAFKA_CERT']
##    cloudkafka_private_key = ENV['CLOUDKARAFKA_PRIVATE_KEY']
##    kafka = Kafka.new(seed_brokers: brokers,
##                  ssl_ca_cert: cloudkafka_ca,
##                  ssl_client_cert: cloudkafka_cert,
##                  ssl_client_cert_key: cloudkafka_private_key)
#    kafka = Kafka.new(seed_brokers: brokers,
#                  ssl_ca_cert: ENV['CLOUDKARAFKA_CA'],
#                  ssl_client_cert: ENV['CLOUDKARAFKA_CERT'],
#                  ssl_client_cert_key: ENV['CLOUDKARAFKA_PRIVATE_KEY'])

    brokers = ENV['CLOUDKARAFKA_2ND_BROKERS'].split(',')
#    kafka = Kafka.new(seed_brokers: brokers,
#                  ssl_ca_cert: ENV['CLOUDKARAFKA_2ND_CA'],
#                  sasl_plain_username: ENV['CLOUDKARAFKA_2ND_USERNAME'],
#                  sasl_plain_password: ENV['CLOUDKARAFKA_2ND_PASSWORD'])

#    kafka = Kafka.new(seed_brokers: brokers,
#                  sasl_scram_username: ENV['CLOUDKARAFKA_2ND_USERNAME'],
#                  sasl_scram_password: ENV['CLOUDKARAFKA_2ND_PASSWORD'])

    kafka = Kafka.new(seed_brokers: brokers,
                  ssl_ca_cert: ENV['CLOUDKARAFKA_2ND_CA'],
                  sasl_scram_mechanism: 'sha256',
                  sasl_scram_username: ENV['CLOUDKARAFKA_2ND_USERNAME'],
                  sasl_scram_password: ENV['CLOUDKARAFKA_2ND_PASSWORD'])


#offsetを全部読んだことにしたく、consumerでcommit_offsetsしてみる。
#    consumer = kafka.consumer(group_id: "my-group")
    consumer = kafka.consumer(group_id: "my-group")

    consumer.commit_offsets

    producer = kafka.producer

#    producer.produce("hello", topic: "lxau-gunman-topic")
#    producer.deliver_messages

    @trendWord = ""
    @tweetTrendStrings = []
#    trendObj = Twitter::REST::Trends.new
    client.trends(id=23424856).each do |trend|    #local_trends(id=23424856)も大体同じ
        puts trend.name
        if @trendWord == "" then
            @trendWord = trend.name
        end
        @tweetTrendStrings << trend.name
        if ( @tweetTrendStrings.length == 10 ) then 
           break
        end
    end

    @tweetString = ""
    @tweetStrings = []
    @tweetMessages = []
#    client.search('ガンマン', :count => 20).each do |tweet|
#    client.search('ガンマン', count: 20).each do |tweet|
#    result_tweets = client.search('時刻', count: 20, result_type: 'recent');  #500くらい検索されてしまう
    result_tweets = client.search(@trendWord)  #take(20)で絞る

#    @tweetString += "result_tweets.attrs[:statuses].size=" + result_tweets.attrs[:statuses].size.to_s + "\n"

    seq = 0
    result_tweets.take(10).each do |tweet|
        seq+=1
        
        seqString = sprintf("%04d", seq)
        tmpString = seqString + "," + tweet.created_at.to_s + "," + tweet.user.screen_name + "," + tweet.text + "\n"
        @tweetString += tmpString
        @tweetStrings << tmpString

        user = client.user(tweet.user.screen_name)
#        p user
#        p user.profile_image_url.to_s
        @tweetMessages << TweetMessage.new(tmpString, user.profile_image_url.to_s)

#        producer.produce(tmpString, topic: "lxau-gunman-topic")
        producer.produce(tmpString, topic: "e1te204u-gunman-topic")

#        producer.deliver_messages
    end

    producer.deliver_messages   #最後に一回でもよいらしい。普通は10行に1回deliverで刻むのかな
    producer.shutdown
    kafka.close

#    sleep(1)
  end

#---------- Kafka Consumer ------------
  def kafkaConsumer
#    sleep(5)

#    brokers = ENV['CLOUDKARAFKA_BROKERS'].split(',')
#    kafka = Kafka.new(seed_brokers: brokers,
#                  ssl_ca_cert: ENV['CLOUDKARAFKA_CA'],
#                  ssl_client_cert: ENV['CLOUDKARAFKA_CERT'],
#                  ssl_client_cert_key: ENV['CLOUDKARAFKA_PRIVATE_KEY'])
#    consumer = kafka.consumer(group_id: "my-group")
#    consumer.subscribe("lxau-gunman-topic")

    brokers = ENV['CLOUDKARAFKA_2ND_BROKERS'].split(',')
#    kafka = Kafka.new(seed_brokers: brokers,
#                  ssl_ca_cert: ENV['CLOUDKARAFKA_2ND_CA'],
#                  sasl_plain_username: ENV['CLOUDKARAFKA_2ND_USERNAME'],
#                  sasl_plain_password: ENV['CLOUDKARAFKA_2ND_PASSWORD'])

    kafka = Kafka.new(seed_brokers: brokers,
                  ssl_ca_cert: ENV['CLOUDKARAFKA_2ND_CA'],
                  sasl_scram_mechanism: 'sha256',
                  sasl_scram_username: ENV['CLOUDKARAFKA_2ND_USERNAME'],
                  sasl_scram_password: ENV['CLOUDKARAFKA_2ND_PASSWORD'])

    consumer = kafka.consumer(group_id: "my-group")
    consumer.subscribe("e1te204u-gunman-topic")

    for i in 1..30   #retry 30 times (30 seconds)
      puts i
      begin
        @kafkaMessages = []
        messages = []
#       consumer.each_message(max_wait_time:10) do |message|
        consumer.each_message do |message|
#         messages <<  message.value + ",[" + message.topic + ":" + message.partition.to_s + ":" + message.key + ":" + message.offset.to_s + "]"
          messages <<  message.value
          @kafkaMessages << KafkaMessage.new(message.value, message.topic, message.partition, message.offset)

          consumer.mark_message_as_processed(message)
          consumer.commit_offsets

          if ( messages.length == 10 ) then 
             break
          end
          #  puts message.topic
          #  puts message.partition
          #  puts message.key
          #  puts message.value
          #  puts message.offset
        end
#     rescue Kafka::ProcessingError => pe
#       p pe.class
#       p pe.message
#       p pe.backtrace
#       p pe.cause

        break # for

      rescue => e
        p e.class
        p e.message
        p e.backtrace
        p e.cause
        sleep(1)   # retry after 1 second (x10 times)
      end
    end #for

#    consumer.commit_offsets

    @guessedCurrentTime = ""
    @sortedKafkaMessages = @kafkaMessages.sort{|m1,m2|
      m1.message <=> m2.message
    }.each do |k|
      puts k.message
      puts k.topic
      puts k.offset
      puts k.partition

      if @guessedCurrentTime == "" then
        @guessedCurrentTime = Time.parse(k.message.gsub(/(....-..-.. ..:..:.. \+....)/, '\1')).in_time_zone('Asia/Tokyo').to_s.sub(/(..:..):../, '\1')
      end

    end

#   @kafkaConsumerString = ""
#   messages.sort.each do |message|
#     @kafkaConsumerString += message.force_encoding("utf-8") + "\n"
##    puts message
#   end

  end

end
