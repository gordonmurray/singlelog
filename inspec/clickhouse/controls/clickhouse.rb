control 'clickhouse-server' do
  impact 1.0
  title 'ClickHouse is running and listening'

  describe service('clickhouse-server') do
    it { should be_running }
  end

  describe port(8123) do
    it { should be_listening }
  end

  describe port(9000) do
    it { should be_listening }
  end
end

control 'hot-table' do
  impact 0.5
  title 'The hot MergeTree table exists'

  describe command("clickhouse-client -q 'EXISTS TABLE logs'") do
    its('stdout') { should match(/1/) }
  end
end
