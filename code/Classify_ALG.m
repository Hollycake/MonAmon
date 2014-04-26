function [ prediction ] = Classify_ALG(classCM,classNCM, testM )
%Classify_ALG - алгоритм голосования по представительным наборам размера 3.
%ВХОД
%classCM - матрица объектов класса (т.е. объекты за класс)
%размер #объектов_класса X #количество_признаков
%classNCM - матрица объектов всех других классов (т.е. объекты аротив класса)
%размер #объектов_НЕ_класса X #количество_признаков
%testM - матрица с объектами для распознавания. размер
%#объектов_распознавания X #количество_признаков
%ВЫХОД
%Матрица #объектов_класса X #1 - оценки за класс для каждого
%распознаваемого объекта

%прогоняем простой кора на данных
for i=1:size(testM,1)
    element=testM(i,:);
    %возмоожно здесь надо будет пройтись по 1 и 2 конюънкциям
    f3=nchoosek(1:size(testM,2),3);
    %берем элемент из testM, прогоняяем всевозможные тройки из f3 и
    %голосуем по матрицам classCM (Current Matrix) и classNCM (Not Current
    %Matrix)
    
    predval=arrayfun(@(x) element(x),f3);%значения конкретных признаков, на данный момент не используется
    
    classNCval=[];%значения classNC на будующих тройках признаков. надо обнулять каждый раз
    %отбрасываем конъюнкции, которые дают на чужих классах >(e=0) откликов
    for k=1:size(classNCM,1)
    classNCval(:,k)=deal(double(all(arrayfun(@(x) classNCM(k,x)==element(x),f3),2)));
    %classNCval+arrayfun(@(x) sum(double(all(classNCM(:,x)==element(x),2))),f3);
    end   
    sum_classNCval=sum(classNCval,2);
    ErrRate=0;%параметр: сколько ошибок мы можем допустить на нашем классе
    f3(sum_classNCval>ErrRate,:)=[];
  
    %ищем количество голосов по оставшимся конъюнкциям
    sumCval=0;
    for k=1:size(classCM,1)
    sumCval=sumCval+sum(double(all(arrayfun(@(x) classCM(k,x)==element(x),f3),2)));
    end
    %задаем нормированное количество голосов за коньюнкцию
    prediction(i)=sum(sumCval)/size(classCM,1);
end


end

