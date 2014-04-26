%% Генерация данных

A = sprandn(10000, 10000, 0.0003) > 0;
A = A(sum(A,2)>=2, any(A,1));
spy(A)

% Веса столбцов
w = rand(1,size(A,2));
w = w / sum(w);


%% Поиск покрытий ГА

% Оценка покрытий по сумме весов столбцов
options.FitnessFunction = @(x)x * w';
options.InstanceCount = 100;

profile on;

tic
[X, scores] = scp_ga( A, options);
toc



