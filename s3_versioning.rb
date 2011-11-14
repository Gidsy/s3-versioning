#!/usr/bin/env ruby
#
# Enable/disable tool for Amazon AWS S3 versioning
#
# Author: Fabrizio Sestito 
# Email: fabrizio@gidsy.com

require 'rubygems'
require 'aws-sdk'
require 'clamp'

def connect
    if not ENV['AMAZON_ACCESS_KEY_ID'] or not ENV['AMAZON_SECRET_ACCESS_KEY'] then
        puts 'Please export your AMAZON_ACCESS_KEY_ID and AMAZON_SECRET_ACCESS_KEY'
        return false
    end

    s3 = AWS::S3.new(
        #:s3_endpoint => "s3-website-eu-west-1.amazonaws.com",
        :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    )
end

def list_buckets
    if s3 = connect then
       return s3.buckets
    else
        puts 'Connection failed'
    end
    
end

def get_bucket(bucket_id)
    if s3 = connect then
       s3.buckets[bucket_id]
    else
        puts 'Connection failed'
    end
end

class S3Versioning < Clamp::Command

    subcommand "enable", "enable versioning for given bucket" do
        parameter "BUCKET_ID", "target bucket"
        def execute
            if target_bucket = get_bucket(bucket_id) then
                target_bucket.enable_versioning
            else
                puts "Bucket ID Invalid or Connection problem"
            end
        end
    end

    subcommand "suspend", "suspend versioning for given bucket" do
        parameter "BUCKET_ID", "target bucket"
        def execute
            if target_bucket = get_bucket(bucket_id) then
                target_bucket.suspend_versioning
            else
                puts "Bucket ID Invalid or Connection problem"
            end
        end
    end

    subcommand "list", "list buckets" do
        def execute
            if buckets = list_buckets then
                buckets.each do |b|
                    begin
                        puts "* #{b.name}   Versioning Enabled: #{b.versioned?}"
                    rescue AWS::S3::Errors::PermanentRedirect => e
                        puts "Warning: PermanentRedirect error for some bucket. Check s3_endpoint."
                    end
                end
            end
        end
    end



    def run(invocation_path = File.basename($0), arguments = ARGV, context = {})
        if arguments.empty? then
            puts self.help
        end
        super(arguments)
    end
end

S3Versioning.run