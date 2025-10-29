clc;
clear;

% PV and Battery Parameters
PV_kWp = 7.56;                         % Total PV capacity
efficiency = 0.85;                     % System efficiency
battery_capacity_kWh = 16.08;          % Total nominal battery capacity
usable_capacity_kWh = battery_capacity_kWh * 0.8 * 0.9;  % 80% DoD, 90% efficiency
initial_SOC = 0.8 * usable_capacity_kWh;  % Initial SOC in kWh
time = 0:1:23;                         % 24-hour simulation (hourly)

% Load Profile Construction
load_profile = zeros(1, 24);
for t = 1:24
    if t >= 8 && t < 18  % 8 AM to 5 PM (working hours)
        % Randomly vary load between 3.0 – 4.96 kW
        load_profile(t) = 3.0 + (4.96 - 3.0) * rand();
    else
        % Non-working hours (constant standby load)
        load_profile(t) = 0.456;
    end
end

% Standard Irradiance Profiles (W/m²)
irradiance_profiles = struct( ...
    'Sunny',      [0 0 0 0 80 200 450 650 820 950 1050 1080 1020 900 720 550 380 220 90 20 0 0 0 0], ...
    'Cloudy',     [0 0 0 0 50 120 200 280 340 420 480 500 480 420 350 300 220 150 80 30 0 0 0 0], ...
    'Rainy',      [0 0 0 0 20 60 100 150 200 250 280 300 280 240 200 150 120 80 40 10 0 0 0 0], ...
    'Harmattan',  [0 0 0 0 40 100 220 350 500 600 700 720 680 600 500 400 300 200 100 40 0 0 0 0] ...
);

% Initialize plot
figure;
hold on;
colors = {'r', 'b', 'g', 'm'};
scenarios = fieldnames(irradiance_profiles);

for i = 1:length(scenarios)
    label = scenarios{i};
    G = irradiance_profiles.(label);
    
    % Calculate PV power output in kW
    pv_output = (G / 1000) * PV_kWp * efficiency;
    
    % Simulate SOC behavior
    SOC = zeros(1, 24);
    SOC(1) = initial_SOC;
    
    for t = 2:24
        net_energy = pv_output(t-1) - load_profile(t-1); % Net energy (kW)
        delta_energy = net_energy * 1;                   % Energy for 1 hour (kWh)
        SOC(t) = SOC(t-1) + delta_energy;
        SOC(t) = min(max(SOC(t), 0), usable_capacity_kWh); % Battery limits
    end
    
    % Normalize SOC to %
    SOC_percent = (SOC / usable_capacity_kWh) * 100;
    plot(time, SOC_percent, 'DisplayName', label, 'LineWidth', 2, 'Color', colors{i});
end

xlabel('Time (Hour of Day)', 'FontWeight', 'bold');
ylabel('Battery State of Charge (%)', 'FontWeight', 'bold');
title('Battery SOC vs. Time (24hr) for 7.56 kWp PV under Different Weather Conditions');
legend('Location', 'best');
grid on;
ylim([0 100]);
xlim([0 23]);
