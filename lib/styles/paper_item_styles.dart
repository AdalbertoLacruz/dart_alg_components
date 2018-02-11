// @copyright @polymer\paper-styles\element-styles\paper-item-styles.js 3.0 20170822
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of styles.alg_components;

///
/// Define mmixins for paper-item-styles.
///
/// To be effective:
/// --paper-item-selected, --paper-item-disabled, --paper-item-focused, --paper-item-focused-before
/// must be defined previously.
///
void definePaperItemStyles() {
  if (Rules.isDefined('paper-item-styles'))
      return;

  defineStyleSheetDefaultTheme();
  defineTypography();

  Rules.defineDefault('--paper-item', '''
      display: block;
      position: relative;
      min-height: var(--paper-item-min-height, 48px);
      padding: 0px 16px;
      ${Rules.use('--paper-font-subhead')}
      border:none;
      outline: none;
      background: white;
      width: 100%;
      text-align: left;''');

  Rules.define('paper-item-styles', '''
      .paper-item {
        ${Rules.use('--paper-item')}
      }

      .paper-item[hidden] {
        display: none !important;
      }

      .paper-item.iron-selected {
        font-weight: var(--paper-item-selected-weight, bold);
        ${Rules.use('--paper-item-selected')}
      }

      .paper-item[disabled] {
        color: var(--paper-item-disabled-color, var(--disabled-text-color));
        ${Rules.use('--paper-item-disabled')}
      }

      .paper-item:focus {
        position: relative;
        outline: 0;
        ${Rules.use('--paper-item-focused')}
      }

      .paper-item:focus:before {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: currentColor;
        content: '';
        opacity: var(--dark-divider-opacity);
        pointer-events: none;
        ${Rules.use('--paper-item-focused-before')}
      }''');
}

