After do |scenario|
  if scenario.status == :failed
    breakpoint
    0
  end
end
