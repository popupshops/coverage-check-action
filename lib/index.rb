# frozen_string_literal: true

require 'net/http'
require 'json'
require 'time'
require_relative './report_adapter'
require_relative './github_check_run_service'
require_relative './github_client'
require_relative './coverage_report'

def read_json(path)
  JSON.parse(File.read(path))
end

@event_json = read_json(ENV['GITHUB_EVENT_PATH']) if ENV['GITHUB_EVENT_PATH']
@github_data = {
  sha: ENV['GITHUB_SHA'],
  token: ENV['INPUT_TOKEN'],
  owner: ENV['GITHUB_REPOSITORY_OWNER'] || @event_json.dig('repository', 'owner', 'login'),
  repo: ENV['GITHUB_REPOSITORY_NAME'] || @event_json.dig('repository', 'name')
}

@coverage_type = ENV['INPUT_TYPE']
@base_report_path = ENV['INPUT_BASE_RESULT_PATH']
@head_report_path = ENV['INPUT_HEAD_RESULT_PATH']

@report = CoverageReport.generate(@coverage_type, @base_report_path, @head_report_path)

GithubCheckRunService.new(@report, @github_data, ReportAdapter).run
