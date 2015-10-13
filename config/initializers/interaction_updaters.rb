[SupplejackApi::InteractionUpdaters::SetMetrics, SupplejackApi::InteractionUpdaters::UsageMetrics].each do |x|
  SupplejackApi::InteractionMetricsWorker.register_interaction_updater(x)
end
