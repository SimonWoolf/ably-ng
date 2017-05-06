use Mix.Config

config :riak_core,
  ring_state_dir: 'ring_data_dir',
  handoff_port: 8099,
  handoff_ip: '127.0.0.1',
  schema_dirs: ['priv']

config :sasl,
  errlog_type: :error

config :lager,
  colored: true,
  error_logger_hwm: 500

config :logger,
  level: :debug,
  handle_sasl_reports: true,
  handle_otp_reports: true
