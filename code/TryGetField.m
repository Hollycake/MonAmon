function value = TryGetField(o, field, default)
%���������� �������� ���� �� ���������, ���� ��� ������, ����� default

    if (isfield(o, field))
        value = getfield(o, field); %#ok<GFLD>
    else
        value = default;
    end

end

