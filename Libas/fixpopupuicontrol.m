function fixpopupuicontrol(fig)
% fixpopupuicontrol is a helper function to fix a popup uicontrol bug.
%
% FIXPOPUPUICONTROL(FIG_HANDLE) takes a figure handle and reparents all the
% popupmenu uicontrols to uipanels to work around a rendering bug in the
% Unix library. This is necessary and works only on Unix and Mac and only
% if the figure is an older version than R14 default.
%
if (nargin == 0)
    fig = allchild(0);
elseif (~ishandle(fig) || ~isa(handle(fig), 'figure'))
    error('Must provide a valid figure handle');
end

for fig_count = 1:length(fig)
    afig = fig(fig_count);
    if (ispc || ~isempty(get(afig, 'JavaFrame')))
        disp('Nothing to fix');
        continue;
    end

    popups = findall(afig, 'type', 'uicontrol', 'style', 'popup');
    
    for pop_count = 1:length(popups)
        apop = popups(pop_count);
        apop_parent = get(apop, 'Parent');
        apop_parent_color = get(0, 'DefaultUicontrolBackgroundColor');
        if (isa (handle(apop_parent), 'figure'))
            apop_parent_color = get(apop_parent, 'Color');
        else
            apop_parent_color = get(apop_parent, 'BackgroundColor');
        end
        
        pop_c = uipanel('Parent', apop_parent, ...
                        'Units', get(apop, 'Units'), ...
                        'Position', get(apop, 'Position'), ...
                        'BackgroundColor', apop_parent_color, ...
                        'BorderType', 'none');
                    
        set(apop, 'Parent', pop_c, 'Units', 'norm', 'Pos', [0 0 1 1]);
    end
end
