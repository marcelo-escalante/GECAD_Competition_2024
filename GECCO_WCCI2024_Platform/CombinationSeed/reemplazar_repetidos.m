function nuevo_vector = reemplazar_repetidos(vector, rango_min, rango_max)
    valores_repetidos = unique(vector); % Encuentra los valores únicos en el vector
    indices_repetidos = find(histcounts(vector, valores_repetidos) > 1); % Encuentra los índices de los valores repetidos

    % Reemplaza los valores repetidos aleatoriamente
    for i = 1:length(indices_repetidos)
        indice = indices_repetidos(i);
        nuevo_valor = randi([rango_min, rango_max]); % Genera un nuevo valor aleatorio dentro del rango especificado
        vector(indice) = nuevo_valor; % Reemplaza el valor repetido por el nuevo valor aleatorio
    end

    nuevo_vector = vector;
end