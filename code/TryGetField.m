function value = TryGetField(o, field, default)
%Попытаться получить поле из структуры, если оно задано, иначе default

    if (isfield(o, field))
        value = getfield(o, field); %#ok<GFLD>
    else
        value = default;
    end

end

