%% ��������� ������

A = sprandn(10000, 10000, 0.0003) > 0;
A = A(sum(A,2)>=2, any(A,1));
spy(A)

% ���� ��������
w = rand(1,size(A,2));
w = w / sum(w);


%% ����� �������� ��

% ������ �������� �� ����� ����� ��������
options.FitnessFunction = @(x)x * w';
options.InstanceCount = 100;

profile on;

tic
[X, scores] = scp_ga( A, options);
toc



