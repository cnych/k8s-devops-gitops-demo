package main

import (
  "net/http"

  "github.com/gin-gonic/gin"
  "github.com/sirupsen/logrus"
)

func main() {
  r := gin.Default()

  r.GET("/", func(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H {
      "msg": "Hello DevOps On Kubernetes",
    })
  })

  r.GET("/health", func(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H {
      "health": true,
    })
  })

  if err := r.Run(":8080"); err != nil {
    logrus.WithError(err).Fatal("Couldn't listen")
  }

}