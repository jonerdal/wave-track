import Toybox.Graphics;
import Toybox.Lang;

// Color tokens and font roles for WaveTrack's screens.
// The "why" behind these choices lives in docs/DESIGN.md; the general
// principles they implement live in docs/DESIGN-RESEARCH.md.
module Theme {

    // --- Color tokens (AMOLED light-on-dark, single accent) ---
    const BACKGROUND as Number = Graphics.COLOR_BLACK;
    const HERO as Number = Graphics.COLOR_WHITE;      // generic hero (non-accent)
    const VALUE as Number = Graphics.COLOR_WHITE;     // secondary stat values
    const LABEL as Number = Graphics.COLOR_LT_GRAY;   // captions / labels
    const HINT as Number = Graphics.COLOR_DK_GRAY;    // bottom hints / version / dividers
    const ACCENT as Number = 0x00B5C2;                // surf teal-blue (tune on device)
    const WARN as Number = Graphics.COLOR_RED;        // destructive
    const GOOD as Number = Graphics.COLOR_GREEN;      // GPS good / save
    const CAUTION as Number = Graphics.COLOR_YELLOW;  // GPS weak

    // --- Font roles (three-tier hierarchy) ---
    const FONT_HERO as Graphics.FontDefinition = Graphics.FONT_NUMBER_HOT;  // numeric hero
    const FONT_TITLE as Graphics.FontDefinition = Graphics.FONT_MEDIUM;     // text hero / title
    const FONT_VALUE as Graphics.FontDefinition = Graphics.FONT_MEDIUM;     // secondary value
    const FONT_VALUE_SMALL as Graphics.FontDefinition = Graphics.FONT_SMALL;
    const FONT_LABEL as Graphics.FontDefinition = Graphics.FONT_TINY;       // label / caption
    const FONT_CAPTION as Graphics.FontDefinition = Graphics.FONT_TINY;
}
