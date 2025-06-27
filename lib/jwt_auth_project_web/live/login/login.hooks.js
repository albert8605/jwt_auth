let LoginHook = {
  mounted() {
    let el = this.el
    this.handleEvent("setCookieAuth", ({ticket, username}) => {
      console.log(ticket)
      set_cookie("ticket", ticket)
      set_cookie("username", username)
      window.location.replace(`${window.location.origin}?ticket=${ticket}`)
    })
    
    this.handleEvent("set_jwt_cookie", ({token, max_age, http_only, secure}) => {
      console.log("Setting JWT token in cookie")
      set_jwt_cookie("jwt_token", token, max_age, http_only, secure)
    })
  }
};

const set_cookie = (name,value) => {
  let today_ = new Date();
  let expires = "; expires=" + today_.setHours(today_.getHours() + 2);
  document.cookie = name + "=" + (value || "")  + expires + "; path=/";
}

const set_jwt_cookie = (name, value, max_age, http_only, secure) => {
  let expires = new Date();
  expires.setTime(expires.getTime() + (max_age * 1000));
  
  let cookie_string = `${name}=${value}; expires=${expires.toUTCString()}; path=/`;
  
  if (secure) {
    cookie_string += "; secure";
  }
  
  if (http_only) {
    // Note: httpOnly can only be set server-side
    // This is just for demonstration, in production use server-side cookie setting
    console.log("JWT token stored (httpOnly should be set server-side)");
  }
  
  document.cookie = cookie_string;
  console.log("JWT token stored in cookie");
}

export {LoginHook};