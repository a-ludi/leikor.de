var AutofillLogin = Class.create({
  initialize: function(options) {
    this.initializeWithOptions(options);
    this.setupCheckbox();
    this.setupNameInputEventHandler();
    this.enableAutofill(true);
  },
  
  initializeWithOptions: function(options) {
    options = AutofillLogin.defaultOptions.merge(options || {});
    
    this.nameInput = options.get('nameInput');
    this.loginInput = options.get('loginInput');
    this.onNameChange = options.get('onNameChange').bindAsEventListener(this);
    this.insertCheckbox = options.get('insertCheckbox');
    this.shouldEnableAutofill = options.get('shouldEnableAutofill');
    this.checkbox = options.get('checkbox');
  },
  
  setupCheckbox: function() {
    this.insertCheckbox(this.checkbox);
    this.checkbox.on('change', function(event) {
      if(this.shouldEnableAutofill(this.checkbox))
        this.enableAutofill();
      else
        this.disableAutofill();
    }.bindAsEventListener(this))
  },
  
  setupNameInputEventHandler: function() {
     this.nameInputEventHandler = this.nameInput.on('keyup', this.onNameChange);
     this.nameInputEventHandler.stop();
  },
  
  enableAutofill: function(dontTriggerChange) {
    this.loginInput.disable();
    this.nameInputEventHandler.start();
    if(! dontTriggerChange)
      this.onNameChange();
  },
  
  disableAutofill: function() {
    this.nameInputEventHandler.stop();
    this.loginInput.enable();
  }
});

AutofillLogin.defaultOptions = $H({
  onNameChange: function(event) { this.nameInput.copyUrlSafe(this.loginInput) },
  checkbox: new Element('input', {type: 'checkbox', checked: false, title: 'manuell ausfüllen'}),
  shouldEnableAutofill: function(checkbox) { return ! checkbox.checked; }
});
