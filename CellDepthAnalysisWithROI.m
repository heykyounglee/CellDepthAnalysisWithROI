% This script performs cell depth analysis. It takes in two files - one
% specifying the coordinates of pia markers and the other specifiying the
% coordinates of cells - and outputs an Excel file, in which each ROI in
% each image occupies a column populated by the depths of all cells in that
% ROIs.

% specify the user for file names. Note that the images in the cell 
% coordinates file can be a subset of the images in the pia marker
% coordinates file.
pia_file_name = input("Enter the name of the .tsv file containing the pia markers' coordinates: ","s");
% Change this line to fit your target directory and file format.
pia_markers_orig = tdfread(strcat("/Users/owensong/Desktop/Lee Lab/CellDepthAnalysisCfos/YanisPia/", strcat(pia_file_name, ".tsv")),'\t');
% specify this line to fit your target directory and file format.
cell_file_name = input("Enter the name of the .tsv file containing the cells' coordinates: ","s");
cell_labels_orig = tdfread(strcat("/Users/owensong/Desktop/Lee Lab/CellDepthAnalysisCfos/YanisCells/", strcat(cell_file_name, ".tsv")),'\t');
% specify the name of the output file
result_file_name = strcat(cell_file_name, "_distances_to_pia.xlsx");
% convert the structs into easy-to-process formats
pia_markers_struct = convert_pia_marker_struct(pia_markers_orig);
cell_labels_struct = convert_cell_label_struct_step1(cell_labels_orig);
fn = fieldnames(cell_labels_struct);
for k = 1:length(fn)
    ROI = fn{k, 1};
    cell_labels_struct.(ROI) = convert_cell_label_struct_step2(cell_labels_struct.(ROI));
end
% loop through all images
images = fieldnames(cell_labels_struct);
prev_rows = 0;
for k = 1:length(images)
    image = images{k,1};
    % calculate the minimum distance from each point to all pia markers
    pia_markers = pia_markers_struct.(image);
    cell_labels_substruct = cell_labels_struct.(image);
    ROIs = fieldnames(cell_labels_substruct);
    for l = 1:length(ROIs)
        ROI = ROIs{l,1};
        cell_labels = cell_labels_substruct.(ROI);
        distances_to_pia = zeros(length(cell_labels.x),1);
        for i = 1:length(cell_labels.x)
            x = cell_labels.x(i);
            y = cell_labels.y(i);
            distances_to_pia(i) = ((x - pia_markers.x(1))^2 + (y - pia_markers.y(1))^2)^0.5;
            for j = 2:length(pia_markers.x)
                dist = ((x - pia_markers.x(j))^2 + (y - pia_markers.y(j))^2)^0.5;
                distances_to_pia(i) = min([distances_to_pia(i), dist]);
            end
        end
        % output the result to an excel
        % add more row names if you have more ROIs than the columns can fit
        rows = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"... 
            "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"... 
            "AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM"... 
            "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ"...
            "BA", "BB", "BC", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BK", "BL", "BM"... 
            "BN", "BO", "BP", "BQ", "BR", "BS", "BT", "BU", "BV", "BW", "BX", "BY", "BZ"...
            "CA", "CB", "CC", "CD", "CE", "CF", "CG", "CH", "CI", "CJ", "CK", "CL", "CM"... 
            "CN", "CO", "CP", "CQ", "CR", "CS", "CT", "CU", "CV", "CW", "CX", "CY", "CZ"...
            "DA", "DB", "DC", "DD", "DE", "DF", "DG", "DH", "DI", "DJ", "DK", "DL", "DM"... 
            "DN", "DO", "DP", "DQ", "DR", "DS", "DT", "DU", "DV", "DW", "DX", "DY", "DZ"...
            "EA", "EB", "EC", "ED", "EE", "EF", "EG", "EH", "EI", "EJ", "EK", "EL", "EM"... 
            "EN", "EO", "EP", "EQ", "ER", "ES", "ET", "EU", "EV", "EW", "EX", "EY", "EZ"...
            "FA", "FB", "FC", "FD", "FE", "FF", "FG", "FH", "FI", "FJ", "FK", "FL", "FM"... 
            "FN", "FO", "FP", "FQ", "FR", "FS", "FT", "FU", "FV", "FW", "FX", "FY", "FZ"...
            "GA", "GB", "GC", "GD", "GE", "GF", "GG", "GH", "GI", "GJ", "GK", "GL", "GM"... 
            "GN", "GO", "GP", "GQ", "GR", "GS", "GT", "GU", "GV", "GW", "GX", "GY", "GZ"...
            "HA", "HB", "HC", "HD", "HE", "HF", "HG", "HH", "HI", "HJ", "HK", "HL", "HM"... 
            "HN", "HO", "HP", "HQ", "HR", "HS", "HT", "HU", "HV", "HW", "HX", "HY", "HZ"...
            "IA", "IB", "IC", "ID", "IE", "IF", "IG", "IH", "II", "IJ", "IK", "IL", "IM"... 
            "IN", "IO", "IP", "IQ", "IR", "IS", "IT", "IU", "IV", "IW", "IX", "IY", "IZ"...
            "JA", "JB", "JC", "JD", "JE", "JF", "JG", "JH", "JI", "JJ", "JK", "JL", "JM"... 
            "JN", "JO", "JP", "JQ", "JR", "JS", "JT", "JU", "JV", "JW", "JX", "JY", "JZ"...
            "KA", "KB", "KC", "KD", "KE", "KF", "KG", "KH", "KI", "KJ", "KK", "KL", "KM"... 
            "KN", "KO", "KP", "KQ", "KR", "KS", "KT", "KU", "KV", "KW", "KX", "KY", "KZ"...
            "LA", "LB", "LC", "LD", "LE", "LF", "LG", "LH", "LI", "LJ", "LK", "LL", "LM"... 
            "LN", "LO", "LP", "LQ", "LR", "LS", "LT", "LU", "LV", "LW", "LX", "LY", "LZ"...
            "MA", "MB", "MC", "MD", "ME", "MF", "MG", "MH", "MI", "MJ", "MK", "ML", "MM"... 
            "MN", "MO", "MP", "MQ", "MR", "MS", "MT", "MU", "MV", "MW", "MX", "MY", "MZ"...
            "NA", "NB", "NC", "ND", "NE", "NF", "NG", "NH", "NI", "NJ", "NK", "NL", "NM"... 
            "NN", "NO", "NP", "NQ", "NR", "NS", "NT", "NU", "NV", "NW", "NX", "NY", "NZ"...
            "OA", "OB", "OC", "OD", "OE", "OF", "OG", "OH", "OI", "OJ", "OK", "OL", "OM"... 
            "ON", "OO", "OP", "OQ", "OR", "OS", "OT", "OU", "OV", "OW", "OX", "OY", "OZ"...

            ];
        writematrix((to_orig_name(image)),result_file_name,'Sheet',1,'Range', strcat(rows(prev_rows + l), '1'));
        writematrix((to_orig_name(ROI)),result_file_name,'Sheet',1,'Range', strcat(rows(prev_rows + l), '2'));
        writematrix(distances_to_pia,result_file_name,'Sheet',1,'Range', strcat(rows(prev_rows + l), '3'));
    end
    prev_rows = prev_rows + length(ROIs);
end
disp(strcat("Analysis done! Output file: ", result_file_name));

function new_struct = convert_pia_marker_struct(orig_struct)
% CONVERT_PIA_MARKER_STRUCT   convert the struct containing all pia markers
% into an easy-to-process format.
    new_struct = struct;
    for k = 1:length(orig_struct.Centroid_X_0xC20xB5m)
        fn = fieldnames(new_struct);
        x_val = orig_struct.Centroid_X_0xC20xB5m(k);
        y_val = orig_struct.Centroid_Y_0xC20xB5m(k);
        image_name = orig_struct.Image(k,1:end);
        dot_pos = strfind(image_name, '.');
        image_name  = image_name(1:dot_pos-1);
        image_name = to_field_name(image_name);
        if ismember(image_name, fn)
            new_struct.(image_name).x = [new_struct.(image_name).x, x_val];
            new_struct.(image_name).y = [new_struct.(image_name).y, y_val];
        else
            new_struct.(image_name) = struct;
            new_struct.(image_name).x = x_val;
            new_struct.(image_name).y = y_val;
        end
    end
    return;
end

function new_struct = convert_cell_label_struct_step1(orig_struct)
% CONVERT_CELL_LABEL_STRUCT_STEP2   convert the struct for the ROIs under
% each image into an easy-to-process format.
    new_struct = struct;
    field_name = 'init';
    for k = 1:length(orig_struct.Centroid_X_0xC20xB5m)
        x_val = orig_struct.Centroid_X_0xC20xB5m(k);
        y_val = orig_struct.Centroid_Y_0xC20xB5m(k);
        parent_name = orig_struct.Parent(k,1:end);
        image_name = orig_struct.Image(k,1:end);
        dot_pos = strfind(image_name, '.');
        image_name  = image_name(1:dot_pos-1);
        image_name = to_field_name(image_name);
        if strcmp(image_name, field_name) == 1
            new_struct.(field_name).Centroid_X_0xC20xB5m = [new_struct.(field_name).Centroid_X_0xC20xB5m, x_val];
            new_struct.(field_name).Centroid_Y_0xC20xB5m = [new_struct.(field_name).Centroid_Y_0xC20xB5m, y_val];
            new_struct.(field_name).ROI = [new_struct.(field_name).ROI; parent_name];
        else
            field_name = image_name;
            new_struct.(field_name) = struct;
            new_struct.(field_name).Centroid_X_0xC20xB5m = x_val;
            new_struct.(field_name).Centroid_Y_0xC20xB5m = y_val;
            new_struct.(field_name).ROI = parent_name;
        end
    end
    return;
end

function new_struct = convert_cell_label_struct_step2(orig_struct)
% CONVERT_CELL_LABEL_STRUCT_STEP2   convert the sub-struct for the cell
% labels under an ROI into an easy-to-process format.
    new_struct = struct;
    for k = 1:length(orig_struct.Centroid_X_0xC20xB5m)
        fn = fieldnames(new_struct);
        x_val = orig_struct.Centroid_X_0xC20xB5m(k);
        y_val = orig_struct.Centroid_Y_0xC20xB5m(k);
        ROI_name = orig_struct.ROI(k,1:end);
        ROI_name = to_field_name(ROI_name);
        if ismember(ROI_name, fn)
            new_struct.(ROI_name).x = [new_struct.(ROI_name).x, x_val];
            new_struct.(ROI_name).y = [new_struct.(ROI_name).y, y_val];
        else
            new_struct.(ROI_name) = struct;
            new_struct.(ROI_name).x = x_val;
            new_struct.(ROI_name).y = y_val;
        end
    end
    return;
end

function newstr = to_field_name(str)
% TO_FIELD_NAME   convert the name of an image/ROI into an appropriate
% field name.
    if strcmp(str(1:6), 'Left: ') == 1
        str = str(7:end);
    elseif strcmp(str(1:7), 'Right: ') == 1
        str = str(8:end);
    end
    c = 0;
    for i = 1:length(str)
        if str(i-c) == '('
            str(i-c) = 'w';
        elseif str(i-c) == ')'
            str(i-c) = 'q';
        elseif str(i-c) == '-'
            str(i-c) = '_';
        elseif str(i-c) == ' '
            str(i-c) = '';
            c = c + 1;
        end
    end
    if isstrprop(str(1),'digit') 
        str = cat(2, 'F', str);
    end
    newstr = str;
    return;
end


function newstr = to_orig_name(str)
% TO_ORIG_NAME  convert the field name for an image/ROI back to its
% original name.
    if str(1) == 'F'
        str = str(2:end);
    end
    for i = 1:length(str)
        if str(i) == 'w'
            str(i) = '(';
        elseif str(i) == 'q'
            str(i) = ')';
        end
    end
    newstr = str;
    return;
end