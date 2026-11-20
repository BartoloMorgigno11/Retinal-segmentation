% RunAnalysis: Esegue l'analisi delle immagini nella cartella 'images'
% utilizzando solo i file XML '_plain.xml' per le annotazioni.

function RunAnalysis()
% === Configurazioni di base ===
imageFolder = '../example_images';
groundtruthFolder = '../groundtruth';
validExts = {'.png', '.jpg', '.jpeg'};

% Controllo cartelle
if ~isfolder(imageFolder) || ~isfolder(groundtruthFolder)
    error('Le cartelle "images" o "groundtruth" non esistono.');
end

% Trova tutte le immagini nella cartella
imageFiles = dir(fullfile(imageFolder, '*.*'));
imageFiles = imageFiles(~[imageFiles.isdir]);  % Rimuove le sottocartelle

if isempty(imageFiles)
    disp('Nessuna immagine trovata nella cartella "images".');
    return;
end

disp(['>> Immagini trovate: ' num2str(length(imageFiles))]);

% Analisi per ogni immagine
for i = 1:length(imageFiles)
    imgName = imageFiles(i).name;
    imgPath = fullfile(imageFolder, imgName);
    fprintf('\n[%d/%d] Analizzo immagine: %s\n', i, length(imageFiles), imgName);

    % Carica immagine
    I = imread(imgPath);
    Iannot = I;

    % Cerca i file XML associati ('_plain.xml')
    [~, name, ~] = fileparts(imgName);
    xmlFiles = dir(fullfile(groundtruthFolder, [name, '_*_plain.xml']));

    if isempty(xmlFiles)
        disp(['  -> Nessun file XML "plain" trovato per ', imgName]);
        continue;
    else
        fprintf('  -> %d file XML trovati\n', length(xmlFiles));
    end

    % Elabora ogni XML
    for j = 1:length(xmlFiles)
        xmlPath = fullfile(groundtruthFolder, xmlFiles(j).name);
        fprintf('    Leggo file XML: %s\n', xmlFiles(j).name);
        Iannot = processLesionXML(Iannot, xmlPath);
    end

    % Mostra l'immagine annotata
    figure('Name', imgName, 'NumberTitle', 'off');
    subplot(1,2,1), imshow(I), title('Originale');
    subplot(1,2,2), imshow(Iannot), title('Annotazioni rilevate');
end
end

% Funzione per elaborare il file XML
function Iannot = processLesionXML(I, xmlPath)
    xmlDoc = xmlread(xmlPath);
    lesions = xmlDoc.getElementsByTagName('marking');
    Iannot = I;
    for k = 0:lesions.getLength-1
        lesion = lesions.item(k);
        typeNode = lesion.getElementsByTagName('markingtype').item(0);
        type = char(typeNode.getFirstChild.getData);

        % Colore in base al tipo di lesione
        switch type
            case 'Hard_exudates', color = 'blue';
            case 'Soft_exudates', color = 'cyan';
            case 'Microaneurysms', color = 'green';
            case 'Haemorrhages', color = 'red';
            otherwise, color = 'white';
        end

        % Estrai le coordinate e disegna i contorni
        regions = lesion.getElementsByTagName('circleregion');
        for r = 0:regions.getLength-1
            region = regions.item(r);
            coordsText = char(region.getElementsByTagName('coords2d').item(0).getTextContent);
            coords = str2double(split(coordsText, ','));
            cx = coords(1);
            cy = coords(2);
            radius = str2double(region.getElementsByTagName('radius').item(0).getTextContent);
            Iannot = insertShape(Iannot, 'Circle', [cx, cy, radius], 'Color', color, 'LineWidth', 2);
        end
    end
end