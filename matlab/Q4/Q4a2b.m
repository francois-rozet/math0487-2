%% Parameters

n = 40;
ni = 5;
l = 100;
m = ni * l;
f = {
    'mean', 'mean', {};
    'std', 'std', {1};
    'std_corr', 'std', {0}
};
g = {'x', 'cf', {}};
country = 'Belgium';
p = 0.95;
tol = 0;

%% Calls

loadData;
pickSamples;

%% Compute x

% Setup
k = size(f, 1) + 1;
f(k, 1) = g;

iCountry = find(strcmp(dataset.Properties.RowNames, country));

% Compute
for i = 1:size(index, 1)
    f{k, 3} = {dataset{iCountry, index{i}}};
    stats.dataset.(index{i}).(f{k, 1}) = feval(f{k, 2}, dataset.(index{i}), f{k, 3}{:});
    for j = 1:size(sample, 1)
        stats.sample.(index{i}).(f{k, 1})
    end
    
    temp = sum(dataset.(index{i}) < dataset{iCountry, index{i}});
	stats.dataset.(index{i}).x = temp / size(dataset, 1);

    % H0
    temp = dataset{iCountry, index{i}} - stats.sample.(index{i}).mean;
    temp = temp ./ stats.sample.(index{i}).std_corr;
	temp = cdf('Normal', temp, 0, 1) <= stats.dataset.(index{i}).x;

    H0.(index{i}) = table;
	H0.(index{i}).(country) = temp(1:l);
	for j = 1:ni - 1
		H0.(index{i}).(['Institute' num2str(j)]) = temp(1 + j * l:(1 + j) * l);
	end
	H0.(index{i}).('OMS') = sum(H0.(index{i}){:, 1:ni}, 2) + tol >= ni;
    
    % proportion
    proportion.(index{i}) = array2table(sum(H0.(index{i}){:,:}, 1) / l);
    proportion.(index{i}).Properties.VariableNames = H0.(index{i}).Properties.VariableNames;
end

%% Compute H0

alpha = 1 - p;

%% Display

for i = 1:size(index, 1)
    disp([index{i} ' :']);
    disp(proportion.(index{i}));
end

%% Clear workspace

clearvars -except dataset index stats sample H0 proportion;
