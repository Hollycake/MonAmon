function [ prediction ] = Classify_ALG(classCM,classNCM, testM )
%Classify_ALG - �������� ����������� �� ���������������� ������� ������� 3.
%����
%classCM - ������� �������� ������ (�.�. ������� �� �����)
%������ #��������_������ X #����������_���������
%classNCM - ������� �������� ���� ������ ������� (�.�. ������� ������ ������)
%������ #��������_��_������ X #����������_���������
%testM - ������� � ��������� ��� �������������. ������
%#��������_������������� X #����������_���������
%�����
%������� #��������_������ X #1 - ������ �� ����� ��� �������
%��������������� �������

%��������� ������� ���� �� ������
for i=1:size(testM,1)
    element=testM(i,:);
    %��������� ����� ���� ����� �������� �� 1 � 2 �����������
    f3=nchoosek(1:size(testM,2),3);
    %����� ������� �� testM, ���������� ������������ ������ �� f3 �
    %�������� �� �������� classCM (Current Matrix) � classNCM (Not Current
    %Matrix)
    
    predval=arrayfun(@(x) element(x),f3);%�������� ���������� ���������, �� ������ ������ �� ������������
    
    classNCval=[];%�������� classNC �� �������� ������� ���������. ���� �������� ������ ���
    %����������� ����������, ������� ���� �� ����� ������� >(e=0) ��������
    for k=1:size(classNCM,1)
    classNCval(:,k)=deal(double(all(arrayfun(@(x) classNCM(k,x)==element(x),f3),2)));
    %classNCval+arrayfun(@(x) sum(double(all(classNCM(:,x)==element(x),2))),f3);
    end   
    sum_classNCval=sum(classNCval,2);
    ErrRate=0;%��������: ������� ������ �� ����� ��������� �� ����� ������
    f3(sum_classNCval>ErrRate,:)=[];
  
    %���� ���������� ������� �� ���������� �����������
    sumCval=0;
    for k=1:size(classCM,1)
    sumCval=sumCval+sum(double(all(arrayfun(@(x) classCM(k,x)==element(x),f3),2)));
    end
    %������ ������������� ���������� ������� �� ����������
    prediction(i)=sum(sumCval)/size(classCM,1);
end


end

