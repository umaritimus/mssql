Facter.add(:random_password) do
  setcode do
    (('a'..'z').to_a.sample(5) + ('A'..'Z').to_a.sample(5) + (0..9).to_a.sample(5) + (('('..'.').to_a + (';'..'>').to_a).sample(1)).sample(16).join
  end
end

Facter.add(:env_temp) do
  setcode do
    ENV['TEMP']
  end
end
