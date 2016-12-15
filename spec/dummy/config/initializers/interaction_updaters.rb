[
  SupplejackApi::InteractionUpdaters::SetMetrics,
  SupplejackApi::InteractionUpdaters::UsageMetrics,
  SupplejackApi::InteractionUpdaters::AllUsageMetric
].each do |x|
  SupplejackApi::InteractionMetricsWorker.register_interaction_updater(x)
end
