# General purpose loader for require_relatived libraries
require 'rubygems'
require 'bundler/setup'
require 'active_support/all'
require 'mechanize'
require 'aws-sdk'
require 'pry'
require 'open3'
require 'yaml'
require 'colorize'
require_relative 'common'
require_relative 'gitbase'
require_relative 'collectortask'
require_relative 'statstask'
require_relative 'lintertask'
require_relative 'lintinstaller'
require_relative 'blissrunner'
require_relative 'requesterpays'
require_relative 'dependencyinstaller'
