#Producer.rb
require 'kafka'

# Create an array with the broker host names.
#brokers = ENV['CLOUDKAFKA_BROKERS'].split(',')
brokers = "steamer-01.srvs.cloudkafka.com:9093,steamer-02.srvs.cloudkafka.com:9093,steamer-03.srvs.cloudkafka.com:9093".split(',')

cloudkafka_ca = 
"MIIC/TCCAeWgAwIBAgIJAInMkmuFOue3MA0GCSqGSIb3DQEBCwUAMBUxEzARBgNV\n
BAMMCnN0ZWFtZXIgQ0EwHhcNMTcwMzIwMTAxNDQ3WhcNMjcwMzE4MTAxNDQ3WjAV\n
MRMwEQYDVQQDDApzdGVhbWVyIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB\n
CgKCAQEA1Ynya8GIQUp+M+y/ZLTGB5NKeohmf6DotK8H3bVziZA4kYQQbnGos1Bt\n
DhaJElOmiN1jn9yed98qWU9O0LwpP0iKe3iqlbA/j3hm88xaNNq8DTC56L3jsEhb\n
upTeqNSNYy9guLIanwWCb2h9mZJrDCsFNzcIlAYjOwSm6X9qDl/GACO2U24UF0V2\n
On+k6CsRFYaSzFI3PqtbUkO33MsAOEQAMclh5usLC/Kh75kIFeDPYqf2wdfzQIaY\n
pZUpZsxYFR1n8OCiFcWBC9xPdPiktRhKS114mf68sp7t2Mv5dFwLvDHKc4zVTM10\n
8v+NPThlFdU0M0zs9fUToEZr6g7d9QIDAQABo1AwTjAdBgNVHQ4EFgQU/icA40s8\n
OKt5Mers/V4KoqEN3YUwHwYDVR0jBBgwFoAU/icA40s8OKt5Mers/V4KoqEN3YUw\n
DAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAS0INqy+tH8HqP6Nvpl8g\n
NfaKtc0sktrILR9iMNjAvvoKmHP807fjcA0qmpcRKI8bshBhhuD/zroK82mWciqY\n
QVrD5bcW1QcTb3HuuISF0R71qnDO/TjtG3fsYsltORzp97AcaOQblvDbNIKkUx0R\n
bg3cBWjY7TjGSqQzwAk5oi4FyX+CsJfA+1GVwIuMFkr0lMyY/rGiHxqFypP05HGS\n
iMqJNv16haPgK7Eg55fMuaMudFOcz+7838cmHOw+DZkjG7hFiVk0uOlhXK2cEyr/\n
UOaCsbJaeA3l7Tk4/RM1ZywRB5qeeQyspwQhp3aSil04L8b0cZ/Qw29KE8YeXtpi\n
hw=="

cloudkafka_cert = 
"MIICoDCCAYgCCQCOC/7dhYpfGDANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDApz\n
dGVhbWVyIENBMB4XDTE3MDcwOTEyNTA1NFoXDTI3MDcwNzEyNTA1NFowDzENMAsG\n
A1UEAwwEbHhhdTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMHgJNwn\n
319s3vCUYuwcTv5+xd3UKvihKoUytZnO/EXcwmZmAu1jVz7uMpLYpQqX0epEj0vm\n
AFGBPphQNssalJmyQkHMCCONjyPwG2bw+e7SnVr0xWc6SROTZjfnN2fxx1DRSJvf\n
UbepyxGC1WJ78ful5HCXwXEKbIi72cVZk88xekpWQU1bhwY2sLWWLGWzootqae0+\n
DtAL59JqpRNDl6BIDuhCPs331ncJNwoeutVG7OMHiA6duaH5cATMe7BoINA2M492\n
czVppPNz7dS6kIoGVeOyZ/QMHQpy8VHQJCeK/lG0XFmL4iCh85+reMN0A8OzM+5l\n
7jhqMU0UMb9oDj8CAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAGbyRK3mnVoTLbp7t\n
mDt69Lo2K+rEWaoqyHzG5IJ7/HT3F4CCw4jAp8ozJmLE/pETezCCB+n0CfjD0eUt\n
ICO5l3HQlDMuwmtKGnxuHyFRW0AJ2DWTTFWCrnS5otZk79fjmLN1kskknPOcNW9n\n
p/fowA6Nr3iv76duQhkBpOHXOxewLW0bZFCBk9mBtG8Sk1mjoefN06zSCIUW8e0B\n
YoFa95cvB7bjhyhGc7lrDe28c084A2bm3oJ7L2+0NeGE0tESi0tu53UCNZoxbwIr\n
+uKCl4nlaDIyO+796H/sA8Q5QmwHcFXLf9pymI9b1jdUe0xbaNjKVwSnCShkXWk/\n
O7sa1Q=="

cloudkafka_private_key = 
"MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDB4CTcJ99fbN7w\n
lGLsHE7+fsXd1Cr4oSqFMrWZzvxF3MJmZgLtY1c+7jKS2KUKl9HqRI9L5gBRgT6Y\n
UDbLGpSZskJBzAgjjY8j8Btm8Pnu0p1a9MVnOkkTk2Y35zdn8cdQ0Uib31G3qcsR\n
gtVie/H7peRwl8FxCmyIu9nFWZPPMXpKVkFNW4cGNrC1lixls6KLamntPg7QC+fS\n
aqUTQ5egSA7oQj7N99Z3CTcKHrrVRuzjB4gOnbmh+XAEzHuwaCDQNjOPdnM1aaTz\n
c+3UupCKBlXjsmf0DB0KcvFR0CQniv5RtFxZi+IgofOfq3jDdAPDszPuZe44ajFN\n
FDG/aA4/AgMBAAECggEAVMHT+3dm/QXQlSaZ9JUPp8zuXeNCgf2bZC3eHIbT3Qr8\n
5d1VDEjwvG9QJsiVpoLm317nsouzue4h2l6/BZ3yNxsqQi+bo0dgu5pdsGxLJ7Bl\n
4Hy/zDg7+FXpSylHHKcjtt43uwUvaXbOczJabTq4eIZ2zw5ZID0pY8GUG+Xka6B2\n
nQzaJeLgcIKFITRkDaqWqYZ2i1b6p01+cV5QTiOQfWRWongWd8BS+11QjMlV4tUj\n
MGjNx1Wdiy8yFHfWsl+j66YynW3JL2QJWRLGOqWaTk1D3COw94a/qmqzqSgT3DEI\n
aHpRLxTXnH8fPi2gHlgZyOycIYhqZUBRNjSdKXT+uQKBgQD7Qkt+kNmp5D1gM6bY\n
SDp3ZUYgHZCzY9bp4qJWt5kLuzy6CFh1IxTPGc3pJLZEw1GYVgdxQ9jYhkEX52K0\n
gXLsjduKYHutMfQ3DdI+NZL3Z3tYO4dez0aL7RzN85DH5wJyh2Y/UGgk7qRzGMyW\n
7B2h2Wqr3F8+dgLQA2lZX2PjAwKBgQDFiKirUduGV6yeYSpHuLurcDi/xj72vUGQ\n
4Dg68muuq6obujWjdmCEEwpuEhEYuTbsOnnGUjjN+uB/Cg0w4AEO89cZDfOqImYn\n
DvSVVLDgsnb09ZzePoQv2G88d9lUgwnU8kiF51Ho1x0SeGfmSD1WESXF/5jWwVWM\n
4u7Wkc0lFQKBgDrG2GhENFb06JKvopEn3F1/2Ha809PTQDw4YyeMDYZcB6mxOBg2\n
27BS5gNrLiRJ2LWdMmKBr6F/Tozr+QAm5B6IVNo7FdN/QxT567vXxoiPsaADVPiN\n
3n/vOPTIzI6m8MCgAgA/rA0vslKmc32+wHPTK4wGolU3QBMvKR7aHMDHAoGATsII\n
DhabIls+lf9Drkj3eolJ9xyB6jrXM35SrR4O1RvYvSlnTX9bSA2XcP9/FY5zWYiP\n
GQWbZHUMoVpOnBgUE/Qg5PptFn6UoCoUVp3n0A8X4t8y5mGirrjq0P8wBcQhXWgk\n
hk8Ol3l9O+oJ8wUGf5RirSkVtTpsc7nfZGnJk2kCgYEAxlBOafetQb2Ff9i7HKGf\n
z74jub6Vc9e7+hPEb0Ksq703ptAje53YAIxtNejV+BoImuWiau0tbCtLhIfwciD8\n
9W6Tto0xyNSTySu0AVnrr84Eqg7d+E3o+AnoR3JbUdiLGql/bCFidkSzVOJOfUfs\n
q1QDYNJROCrWFC1UMNtUxLU="

# Create a Apache Kafka client.
kafka = Kafka.new(seed_brokers: brokers,
                  ssl_ca_cert: cloudkafka_ca,
                  ssl_client_cert: cloudkafka_cert,
                  ssl_client_cert_key: cloudkafka_private_key)
kafka = Kafka.new(seed_brokers: brokers,
                  ssl_ca_cert: ENV['CLOUDKAFKA_CA'],
                  ssl_client_cert: ENV['CLOUDKAFKA_CERT'],
                  ssl_client_cert_key: ENV['CLOUDKAFKA_PRIVATE_KEY'])

producer = kafka.producer

topic_prefix = ENV['CLOUDKAFKA_TOPIC_PREFIX']
loop do
  producer.produce("hello", topic: "#{topic_prefix}default")

  # If this line fails with Kafka::DeliveryFailed we *may* have succeeded in delivering
  # the message to Kafka but won't know for sure.
  producer.deliver_messages
  # If we get to this line we can be sure that the message has been delivered to Kafka!
  sleep 1
end