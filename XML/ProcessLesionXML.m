function Iout = ProcessLesionXML(I, xmlPath)
    % Crea una factory per parser che non validano la DTD
    factory = javax.xml.parsers.DocumentBuilderFactory.newInstance();
    factory.setValidating(false);  % Disabilita la validazione della DTD
    factory.setNamespaceAware(false);
    
    % Crea un parser XML senza validazione
    builder = factory.newDocumentBuilder();
    
    % Leggi il file XML senza tentare di scaricare la DTD
    xmlDoc = builder.parse(java.io.File(xmlPath));
    Iout = I;
    
    % Estrai i nodi delle lesioni
    markings = xmlDoc.getElementsByTagName('marking');
    
    for i = 0:markings.getLength - 1
        marking = markings.item(i);
        markingType = char(marking.getElementsByTagName('markingtype').item(0).getTextContent());
        confidenceLevel = char(marking.getElementsByTagName('confidencelevel').item(0).getTextContent());
        
        % Filtra per livello di confidenza (High o Medium)
        if ~ismember(confidenceLevel, {'High', 'Medium'})
            continue;
        end
        
        % Estrai le coordinate
        if marking.getElementsByTagName('circleregion').getLength > 0
            region = marking.getElementsByTagName('circleregion').item(0);
            centroid = str2num(char(region.getElementsByTagName('centroid').item(0).getTextContent()));
            radius = str2double(char(region.getElementsByTagName('radius').item(0).getTextContent()));
            Iout = insertShape(Iout, 'Circle', [centroid, radius], 'Color', lesionColor(markingType), 'LineWidth', 2);
        
        elseif marking.getElementsByTagName('polygonregion').getLength > 0
            region = marking.getElementsByTagName('polygonregion').item(0);
            coordsList = region.getElementsByTagName('coords2d');
            polygon = [];
            for j = 0:coordsList.getLength - 1
                coord = str2num(char(coordsList.item(j).getTextContent()));
                polygon = [polygon; coord];
            end
            Iout = insertShape(Iout, 'Polygon', polygon(:)', 'Color', lesionColor(markingType), 'LineWidth', 2);
        end
    end
end