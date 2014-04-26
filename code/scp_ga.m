function [X, Scores] = scp_ga(A, options)
% ����� ��������� �������� ������� A ������������ ����������

[m,n] = size(A);

gaoptions = TryGetField(options, 'GAOptions', ...
    gaoptimset('Display', 'off', ...
               'Vectorized', 'on', ...
               'PopInitRange', [-1;1]));

InstanceCount = TryGetField(options, 'InstanceCount', 10);

% ����������� ����� � ����������� ��������� ��������� ��� ��������� ���������� �������
PopulationSize = gaoptimget(gaoptions,'PopulationSize', 100);
if (InstanceCount > 0 && length(PopulationSize) == 1)
    SubpopulationSize = max(round(PopulationSize / InstanceCount), 10);
    SubpopulationCount = max(PopulationSize / SubpopulationSize, 1);

    gaoptions = gaoptimset(gaoptions, 'PopulationSize', ...
        repmat(SubpopulationSize, 1, SubpopulationCount));
end

% �������� ������� �������� ������
creationFcn = gaoptimget(gaoptions, 'CreationFcn', @gacreationuniform);
gaoptions = gaoptimset(gaoptions, 'CreationFcn', ...
    @(GenomeLength, FitnessFcn, gaoptions)...    
        FixPopulation(A, creationFcn(GenomeLength, FitnessFcn, gaoptions)));

% �������� ������� ������� ������
mutationFcn = gaoptimget(gaoptions, 'MutationFcn', @mutationgaussian);
gaoptions = gaoptimset(gaoptions, 'MutationFcn', ...
    @(parents, gaoptions, nvars, FitnessFcn, ...
        state, thisScore, thisPopulation)...    
        FixPopulation(A, mutationFcn(parents, gaoptions, nvars, FitnessFcn, ...
            state, thisScore, thisPopulation)));

% �������� ������� ����������� ������
crossoverFcn = gaoptimget(gaoptions, 'CrossoverFcn', @crossoverintermediate);
gaoptions = gaoptimset(gaoptions, 'CrossoverFcn', ...
    @(parents, gaoptions, nvars, FitnessFcn, ...
            unused,thisPopulation)...    
        FixPopulation(A, crossoverFcn(parents, gaoptions, nvars, FitnessFcn, ...
            unused,thisPopulation)));
        
fitnessFcn = TryGetField(options, 'FitnessFunction',  @(X)sum(X,2));

%gaoptions = gaoptimset(gaoptions, 'PlotFcns', @gaplotbestf);
%gaoptions = gaoptimset(gaoptions, 'StallGenLimit', 100);


% ����������, ������� ������ "����������" (��������, ����� ���������)
%NoContained = TryGetField(options, 'NoContains', []);

% ������, �� ���� �� ������� ��������� ������
%NoCover = TryGetField(options, 'NoCoverRows', []);

% ������, �� ������� ���������� ������� ���� �� ����
%AnyCover = TryGetField(options, 'AnyCoverRows', []);

% ������, �� ������� ���������� �� ������� ���� �� ����
%AnyNoCover = TryGetField(options, 'AnyNoCoverRows', []);

X = [];
Scores = [];

 num_iter = 1;
 iter = 1;

while (length(Scores) < InstanceCount && iter <= num_iter)

    % � ������ ����� ������ n ����� ���������� �������, � ��������,
    % ����������� n ����� --- ��������� �������� �������,
    % ����������� m ����� --- ��������� ����� �������
    [~, ~, ~, ~, population, scores] = ...
        ga(@(population)fitnessFcn(GetColumnSetsFromPopulation(n, population)), ...
        2*n+m,[],[],[],[],[],[],[], gaoptions);
        
    x = GetColumnSetsFromPopulation(n, population);
    
    s = size(X, 1);
    
    X = [X; x];
    Scores = [Scores; scores];

    [X, k] = unique(X, 'rows');
    Scores = Scores(k);
    
    iter = iter + 1;
    
    if (size(X,1) <= s)
        break;
    end
end

end


function columnSets = GetColumnSetsFromPopulation(n, population)
% �������� ������ ��������, �������������� � ����� ������ ���������
    columnSets = population(:, 1:n)>0;
end

function population = FixPopulation(A, population)
% ������� ������ � ��������� �������� � ������������ ���������

    n = size(A, 2);

    r = size(population,1);
    
    if (r == 1)
        population = FixInstance(A, n, population);
    else
        for i = 1:r
            population(i, :) = FixInstance(A, n,  population(i, :));
        end    
    end
    
    
end

function instance = FixInstance(A, n, instance)
% ������� ����� ������� � ������������� ��������

    % �������� ����� ��������
    cover = GetColumnSetsFromPopulation(n, instance);
        
    % �������� ������� �������� � ����� �������
    [~, cols] = sort(instance(n+1:n+n));
    [~, rows] = sort(instance(n+n+1:end));
    
    %L = A(rows, cols);
    % ��������� ����������� ��� �������� ������� � �������, ���������� �
    % �����
    cover = FixCover(A, cover, rows, cols);
    % ������� ������ ��� �������������� ������� � �������� �������
    cover = ReduceCover(A, cover, cols);
        
    k = cover & instance(1:n) == 0;
    instance(k) = 1;
    % ����, ��� �������� ����
    k = ((2*cover-1) .* instance(1:n)) < 0;
    % � ������ ���
    instance(k) = -instance(k);
end

function cover = FixCover2(BoolM, cover, rows, cols)
% ��������� ����� cover �� �������� ������� A
   
    col = cols(cover(cols));
    num_col = length(col);
    
    M = BoolM(:, col);  
    sum_cov = sum(M,2);    
    
    %���������� ������� ������ �� ��������, 
    %���������, �������� �� ����� ���������        
    for j = 1:num_col
        cover( col(j) ) = true;
        sum_cov = sum_cov + M(:, j);
        if all(sum_cov)
            return        
        end           
    end              
end

function cover = FixCover(A, cover, rows, cols)
% ��������� ����� cover �� �������� ������� A
    
    %mark uncovered rows in A
    uncovered = ~any(A(:,cover),2);
    
    if ~any(uncovered)
        return
    end
    
    % uncovered = full(~any(A(:,cover~=0),2)); % Petr's
    rows = rows(uncovered(rows));
        
    L = A(rows, cols);
    [~, firstcols] = max(L,[],2);
    
    for r = 1:length(rows)
        if (uncovered(rows(r)))
          t = firstcols(r);
          cover(cols(t)) = true;
          uncovered(rows(L(:,t))) = 0;        
        end               
    end
    
%     for r = 1:length(rows)
%         i = rows(r);
%         if (~uncovered(i))
%             continue;
%         end
%         
%         t = firstcols(r);
%         j = cols(t);
%         cover(j) = true;
%         uncovered(rows(L(:,t))) = 0;
%         
%         %if (nnz(uncovered) == 0)
%         %    break;
%         %end        
%     end
    
end

function irred_cover = ReduceCover(BoolM, cover, cols)  

    col = cols(cover(cols));
    num_col = length(col);
    
    irred_cover = cover;
    
    M = BoolM(:, col);  
    sum_cov = sum(M,2);    
    
    %���������� ������� ������ �� ��������, 
    %���������, �������� �� ����� ���������        
    for j = num_col:-1:1
%         sum_cov = sum_cov - M(:, j);
%         if all(sum_cov)
%             irred_cover( col(j) ) = 0;
%         else
%             sum_cov = sum_cov + M(:, j);
%         end 
        sum_cov_j = sum_cov - M(:,j);
        if all(sum_cov_j)
            sum_cov = sum_cov_j;
            irred_cover( col(j) ) = 0;
        end           
    end          
end

function cover = ReduceCover2(A, cover, cols)
% ������� ������ ������� �� ��������, ����� �������� ������������ ��������
    
    b = sum(A(:,cover),2)-1;
    if (any(b < 0))
        cover = [];
        return;
    end
        
    %r1 = nnz(cover);    % ����� �������� � ������
    %r2 = nnz(ccols);    
    %if (all(ccols == cover))
    %    return;
    %end

    % �������, ��� ������� ��� ������ � ����� ��������
    reduce = cover & ~any(A(b==0, :),1);
    k = cols(reduce(cols));
            
    % ��������, ������� � ��������� ��������        
    for j = k(length(k):-1:1)
        
        %if (ccols(j))
        %    continue;
        %end
        
        i = A(:,j);
                
        if (any(b(i)==0))
            continue;
        end
        
        b(i) = b(i) - 1;
        cover(j) = false;
        
        %r1 = r1-1;
        
        %if (any(c==1))        
        %    ccols(cover & ~ccols) = any(A(i(c==1), cover & ~ccols), 1);        
        %    if (all(ccols == cover))
        %        break;
        %    end        
        %end
        
        % ���� ������, � ������� b ����� ��������� ����� ����� 1
        %r2 = r2 + nnz(c==1);
        %if (r2 >= r1)
        %    break;
        %end        
    end

end


% function L =  ClearDependentRows(L)
% 
%     s = sum(L,2);
%     checked = s==0;    
%     [~,k] = sort(s);
%                         
%     while (any(~checked))
%                 
%         for i = k(~checked(k))'
%             row = L(i,:);
%             rows = sum(L(:, row), 2) == sum(row);
%             checked(rows) = 1;
%                 
%             rows(i) = 0;
%             if (any(rows))
%                 L(rows,:) = 0;
%                 s(rows) = 0;
%                 break;
%             end
%         end
%         
%     end
% end

% function [i,j] = FindIdentitySubmatrix(L)
% % ����� ���� ��������������� ���������� � ������� L
% 
%     m = size(L,1);
%     
%     i = [];
%     j = [];
%     covered = sparse(m,1);
%     
%     %L = ClearDependentRows(L);
%     
%     while (nnz(L) > 0)
%         [r,c] = find(L, 1);
%             
%         row = L(r,:);
%         col = L(:,c);
% 
%         if (any(all(L(~(covered | col), ~row)==0, 2)))
%             L(r, c) = 0;
%         else
%             L(col, :) = 0;
%             L(:, row) = 0;
%             L = ClearDependentRows(L);
%             i = [i,r];
%             j = [j,c];    
%             covered = covered | col;
%         end
%     end
% 
% end


